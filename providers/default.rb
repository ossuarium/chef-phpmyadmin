#
# Cookbook Name:: phpmyadmin
# Provider:: default
#

require 'digest/sha1'

def whyrun_supported?
  true
end

action :create do
  create_default
end

action :delete do
  delete_default
end

action :destroy do
  delete_default
end

private

def set_attributes
  new_resource.domain ||= node['hostname']

  new_resource.id = "#{new_resource.service.name}_phpmyadmin"
  new_resource.mysql_connection = {
    host: 'localhost',
    port: node['mysql']['port'].to_i,
    username: 'root',
    password: node['mysql']['server_root_password']
  }
end

def create_default
  set_attributes

  protocols = ['']
  protocols << '-ssl' if new_resource.ssl

  # Create the LAMP app.
  core_lamp_app new_resource.id do
    moniker 'phpmyadmin'
    service new_resource.service
    shared node['phpmyadmin']['shared']
    php_options node['phpmyadmin']['php_options']
    database true
    mysql_connection new_resource.mysql_connection
    db_name "phpmyadmin_#{new_resource.service.name}"
    db_client 'localhost'
  end

  # Create `/etc/apache2/services/service_name/phpmyadmin.d/instance(-ssl).conf`.
  protocols.each do |ssl|
    template "#{new_resource.id}_instance.conf" do
      path lazy {
        resources("core_lamp_app[#{new_resource.id}]").conf_dir + "/instance#{ssl}.conf"
      }
      source 'apache-instance-phpmyadmin.conf.erb'
      cookbook 'phpmyadmin'
      variables lazy {
        {
          ssl_enabled: new_resource.ssl,
          ssl: ssl.empty? ? false : true,
          server_name: new_resource.domain,
          confroot: resources("core_lamp_app[#{new_resource.id}]").conf_dir,
          docroot: resources("core_lamp_app[#{new_resource.id}]").dir
        }
      }
      notifies :reload, 'service[apache2]'
    end
  end

  # Create `/etc/apache2/sites-available/service_name_phpmyadmin(-ssl).conf`.
  protocols.each do |ssl|
    template "#{node['apache']['dir']}/sites-available/#{new_resource.id}#{ssl}.conf" do
      source 'apache-vhost.conf.erb'
      cookbook 'core'
      variables lazy {
        {
          name: new_resource.id,
          ssl: ssl.empty? ? false : true,
          server_name: new_resource.domain,
          server_aliases: new_resource.aliases,
          docroot: resources("core_lamp_app[#{new_resource.id}]").dir,
          directory_index: ['index.php', 'index.html', 'index.htm'],
          includes: [resources("core_lamp_app[#{new_resource.id}]").conf_dir + "/instance#{ssl}.conf"]
        }
      }
      notifies :reload, 'service[apache2]'
      only_if { new_resource.vhost }
    end
  end

  # Create `/etc/apache2/conf.d/service_name_phpmyadmin.conf`.
  template "#{node['apache']['dir']}/conf.d/#{new_resource.id}.conf" do
    source 'apache-alias-phpmyadmin.conf.erb'
    cookbook 'phpmyadmin'
    variables lazy {
      {
        confroot: resources("core_lamp_app[#{new_resource.id}]").conf_dir,
        docroot: resources("core_lamp_app[#{new_resource.id}]").dir,
        alias_path: new_resource.alias_path
      }
    }
    action new_resource.vhost ? :delete : :create
    notifies :reload, 'service[apache2]'
  end

  # Create `/srv/service_name/phpmyadmin`.
  directory new_resource.id do
    path lazy { resources("core_lamp_app[#{new_resource.id}]").dir }
  end

  # Create `/srv/service_name/shared/phpmyadmin/config.inc.php`.
  template "lamp_app_#{new_resource.id}_config" do
    path lazy {
      resources("core_lamp_app[#{new_resource.id}]").shared_dir + '/config.inc.php'
    }
    source 'phpmyadmin-config.inc.php.erb'
    cookbook 'phpmyadmin'
    group node['apache']['group']
    mode '0640'
    variables lazy {
      {
        app: resources("core_lamp_app[#{new_resource.id}]"),
        blowfish_secret: Digest::SHA1.hexdigest(IO.read('/dev/urandom', 2048))
      }
    }
  end

  # Download and extract the package.
  tar_extract("#{node['phpmyadmin']['mirror']}/#{node['phpmyadmin']['version']}" \
              "/phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages.tar.gz") do
    target_dir new_resource.service.dir
    checksum node['phpmyadmin']['checksum']
    creates(
      "#{new_resource.service.dir}/phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages"
    )
  end

  # Deploy the release.
  execute "lamp_app_#{new_resource.id}_deploy" do
    command lazy {
      'rm -rf phpmyadmin/* && cp -a' \
      " phpMyAdmin-#{node['phpmyadmin']['version']}-all-languages/* phpmyadmin" \
      " && chgrp -R #{node['apache']['group']} phpmyadmin/*" \
      ' && sed -i s/phpmyadmin/' +
      resources("core_lamp_app[#{new_resource.id}]").db_name +
      "/g phpmyadmin/#{node['phpmyadmin']['sql']}"
    }
    cwd new_resource.service.dir
    creates lazy {
      resources("core_lamp_app[#{new_resource.id}]").dir +
      "/RELEASE-DATE-#{node['phpmyadmin']['version']}"
    }
  end

  # Create a link to `config.inc.php`.
  link "#{new_resource.service.dir}/phpmyadmin/config.inc.php" do
    to lazy {
      resources("core_lamp_app[#{new_resource.id}]").shared_dir + '/config.inc.php'
    }
  end

  # Link shared directories.
  node['phpmyadmin']['shared'].each do |path|
    link "#{new_resource.service.dir}/phpmyadmin/#{path}" do
      to lazy {
        resources("core_lamp_app[#{new_resource.id}]").shared_dir + "/#{path}"
      }
    end
  end

  # Create control database tables.
  mysql_database "#{new_resource.id}_create_tables" do
    connection new_resource.mysql_connection
    database_name lazy { resources("core_lamp_app[#{new_resource.id}]").db_name }
    sql lazy { ::File.open(
        resources("core_lamp_app[#{new_resource.id}]").dir + "/#{node['phpmyadmin']['sql']}"
      ).read
    }
    action :query
  end

  # Enable or disable the site.
  ['', '-ssl'].each do |ssl|
    apache_site "#{new_resource.id}#{ssl}" do
      enable true
    end if new_resource.vhost

    apache_site "#{new_resource.id}#{ssl}" do
      enable false
    end unless new_resource.vhost
  end
end

def delete_default
  set_attributes

  # Disable the site.
  ['', '-ssl'].each do |ssl|
  apache_site "#{new_resource.id}#{ssl}" do
    enable false
  end
  end

  # Delete `/etc/apache2/sites-available/service_name_phpmyadmin(-ssl).conf`.
  ['', '-ssl'].each do |ssl|
    template "#{node['apache']['dir']}/sites-available/#{new_resource.id}#{ssl}.conf" do
      source 'apache-vhost.conf.erb'
      cookbook 'core'
      action :delete
      notifies :reload, 'service[apache2]'
    end
  end

  # Delete `/etc/apache2/conf.d/service_name_phpmyadmin.conf`.
  template "#{node['apache']['dir']}/conf.d/#{new_resource.id}.conf" do
    source 'apache-alias-phpmyadmin.conf.erb'
    cookbook 'phpmyadmin'
    action :delete
    notifies :reload, 'service[apache2]'
  end

  # Delete `/srv/service_name/phpmyadmin`.
  directory new_resource.id do
    path lazy { resources("core_lamp_app[#{new_resource.id}]").dir }
    recursive true
    action :delete
  end

  # Delete `/srv/service_name/shared/phpmyadmin/config.inc.php`.
  template "lamp_app_#{new_resource.id}_config" do
    path lazy {
      resources("core_lamp_app[#{new_resource.id}]").shared_dir + '/config.inc.php'
    }
    source 'phpmyadmin-config.inc.php.erb'
    cookbook 'phpmyadmin'
    action :delete
  end

  # Delete or destroy the LAMP app.
  core_lamp_app new_resource.id do
    moniker 'phpmyadmin'
    service new_resource.service
    database true
    mysql_connection new_resource.mysql_connection
    db_name "phpmyadmin_#{new_resource.service.name}"
    db_client 'localhost'
    action new_resource.action
  end
end

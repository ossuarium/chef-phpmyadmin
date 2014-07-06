#
# Cookbook Name:: phpmyadmin
# Provider:: default
#

require 'digest/sha1'

def whyrun_supported?
  true
end

action :create do
  converge_by("Creating #{@new_resource}") do
    create_default
  end
end

action :delete do
  converge_by("Deleting #{@new_resource}") do
    delete_default
  end
end

action :destroy do
  converge_by("Destroying #{@new_resource}") do
    delete_lamp_app
  end
end

private

def set_attributes
  new_resource.domain ||= node['hostname']

  new_resource.id = "#{new_resource.service.name}_phpmyadmin"
  new_resource.mysql_connection = {
    host: 'localhost',
    username: 'root',
    password: node['mysql']['server_root_password']
  }
end

def create_default
  set_attributes

  core_lamp_app new_resource.id do
    moniker 'phpmyadmin'
    service new_resource.service
    database true
    mysql_connection new_resource.mysql_connection
  end

  template "#{new_resource.id}_instance.conf" do
    path lazy {
      resources("core_lamp_app[#{new_resource.id}]").conf_dir + '/instance.conf'
    }
    source 'apache-instance-phpmyadmin.conf.erb'
    variables lazy {
      {
        name: resources("core_lamp_app[#{new_resource.id}]").name,
        moniker: resources("core_lamp_app[#{new_resource.id}]").moniker,
        confroot: resources("core_lamp_app[#{new_resource.id}]").conf_dir,
        docroot: resources("core_lamp_app[#{new_resource.id}]").dir + '/current'
      }
    }
    notifies :reload, 'service[apache2]'
  end

  template "#{node['apache']['dir']}/sites-available/#{new_resource.id}.conf" do
    source 'apache-vhost.conf.erb'
    cookbook 'core'
    variables lazy {
      {
        name: new_resource.id,
        server_name: new_resource.domain,
        server_aliases: new_resource.aliases,
        docroot: resources("core_lamp_app[#{new_resource.id}]").dir + '/current',
        directory_index: ['index.php', 'index.html', 'index.htm'],
        includes: [resources("core_lamp_app[#{new_resource.id}]").conf_dir + '/instance.conf']
      }
    }
    notifies :reload, 'service[apache2]'
  end

  directory "lamp_app_#{new_resource.id}" do
    path lazy { resources("core_lamp_app[#{new_resource.id}]").dir }
  end

  template "lamp_app_#{new_resource.id}_config" do
    path lazy {
      resources("core_lamp_app[#{new_resource.id}]").shared_dir + '/config.inc.php'
    }
    source 'phpmyadmin-config.inc.php.erb'
    variables(
      blowfish_secret: Digest::SHA1.hexdigest(IO.read('/dev/urandom', 2048))
    )
  end

  link "#{new_resource.id}_shared" do
    target_file "#{new_resource.service.dir}/phpmyadmin/shared"
    to lazy { resources("core_lamp_app[#{new_resource.id}]").shared_dir }
  end

  deploy new_resource.id do
    deploy_to "#{new_resource.service.dir}/phpmyadmin" # can't use lazy here
    repo node['phpmyadmin']['repo']
    revision node['phpmyadmin']['revision']
    group node['apache']['group']
    keep_releases 1
    create_dirs_before_symlink []
    purge_before_symlink []
    symlinks({})
    symlink_before_migrate({})
  end

  mysql_database "#{new_resource.id}_sql" do
    connection new_resource.mysql_connection
    sql lazy { File.open(
        resources("core_lamp_app[#{new_resource.id}]").dir + node['phpmyadmin']['sql']
      ).read
    }
    action :query
  end

  apache_site new_resource.id do
    enable true
  end
end

def delete_default
  set_attributes

  apache_site new_resource.id do
    enable false
  end

  template "#{node['apache']['dir']}/sites-available/#{new_resource.id}" do
    source 'apache-vhost.conf.erb'
    cookbook 'core'
    action :delete
    notifies :reload, 'service[apache2]'
  end

  directory "lamp_app_#{new_resource.id}" do
    path lazy { resources("core_lamp_app[#{new_resource.id}]").dir }
    recursive true
    action :delete
  end

  core_lamp_app new_resource.id do
    moniker 'phpmyadmin'
    service new_resource.service
    database new_resource.mysql_connection.nil? ? false : true
    mysql_connection new_resource.mysql_connection
    action new_resource.action
  end
end

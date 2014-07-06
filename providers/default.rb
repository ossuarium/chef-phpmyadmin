#
# Cookbook Name:: phpmyadmin
# Provider:: default
#

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
        docroot: resources("core_lamp_app[#{new_resource.id}]").dir
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
        docroot: resources("core_lamp_app[#{new_resource.id}]").dir,
        directory_index: ['index.php', 'index.html', 'index.htm'],
        includes: [resources("core_lamp_app[#{new_resource.id}]").conf_dir + '/instance.conf']
      }
    }
    notifies :reload, 'service[apache2]'
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
    action :delete
    notifies :reload, 'service[apache2]'
  end

  core_lamp_app new_resource.id do
    moniker 'phpmyadmin'
    service new_resource.service
    database new_resource.mysql_connection.nil? ? false : true
    mysql_connection new_resource.mysql_connection
    action :delete
  end
end

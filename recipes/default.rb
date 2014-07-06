#
# Cookbook Name:: phpmyadmin
# Recipe:: default
#

include_recipe 'tar::default'
include_recipe 'core::lamp_app_server'
include_recipe 'php::module_gd'
include_recipe 'php::module_mcrypt'

node['phpmyadmin']['extensions'].each do |extension|
  php_pear extension do
    action :upgrade
  end
end

node['phpmyadmin']['instances'].each do |instance|
  phpmyadmin instance[:service] do
    service resources(core_service: instance[:service])
    domain instance[:domain] if instance[:domain]
    aliases instance[:aliases] if instance[:aliases]
    action instance[:action] if instance[:action]
  end
end

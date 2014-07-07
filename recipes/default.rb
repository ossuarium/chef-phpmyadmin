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

node['phpmyadmin']['instances'].each do |instance, params|
  phpmyadmin instance do
    service resources(core_service: instance)
    domain params[:domain] if params[:domain]
    aliases params[:aliases] if params[:aliases]
    action params[:action] if params[:action]
  end
end

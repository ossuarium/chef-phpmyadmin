#
# Cookbook Name:: phpmyadmin
# Recipe:: default
#

node.default['php-modules']['modules']['mcrypt'] = true

include_recipe 'tar::default'
include_recipe 'core::lamp_app_server'

node['phpmyadmin']['extensions'].each do |extension|
  php_pear extension do
    action :upgrade
  end
end

node['phpmyadmin']['instances'].each do |instance, params|
  phpmyadmin instance do
    service resources(core_service: instance)
    ssl params[:ssl] if params[:ssl]
    alias_path params[:alias_path] if params[:alias_path]
    vhost params[:vhost] if params[:vhost]
    domain params[:domain] if params[:domain]
    aliases params[:aliases] if params[:aliases]
    action params[:action] if params[:action]
  end
end

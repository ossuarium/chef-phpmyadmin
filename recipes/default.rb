#
# Cookbook Name:: phpmyadmin
# Recipe:: default
#

include_recipe 'git::default'
include_recipe 'core::lamp_app_server'
include_recipe 'php::module_mcrypt'

node['phpmyadmin']['instances'].each do |instance|
  phpmyadmin instance[:service] do
    service resources(core_service: instance[:service])
    domain instance[:domain] if instance[:domain]
    aliases instance[:aliases] if instance[:aliases]
    action instance[:action] if instance[:action]
  end
end

#
# Cookbook Name:: phpmyadmin
# Resource:: default
#

=begin
#<
@action create creates the instance.
@action delete deletes the instance.

@attribute name the name of the instance.
@attribute service the core_service to use for the instance.
@attribute domain the domain to use for the web server.
@attribute aliases the domain aliases to use for the web server.
#>
=end

default_action :create

actions :create, :delete

attribute :name, kind_of: String, required: true, name_attribute: true
attribute :service, kind_of: Chef::Resource, required: true
attribute :domain, kind_of: String
attribute :aliases, kind_of: Array, default: []

attr_accessor :id, :mysql_connection

attr_writer :domain

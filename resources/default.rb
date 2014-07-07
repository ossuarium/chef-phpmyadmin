#
# Cookbook Name:: phpmyadmin
# Resource:: default
#

=begin
#<
@action create creates the instance.
@action delete deletes the instance.
@action destroy deletes the instance, database, and shared directory.

@attribute name the name of the instance.
@attribute service the core_service to use for the instance.
@attribute vhost whether to setup a vhost for this instance.
@attribute domain the domain to use for the web server.
@attribute aliases the domain aliases to use for the web server.
#>
=end

default_action :create

actions :create, :delete, :destroy

attribute :name, kind_of: String, required: true, name_attribute: true
attribute :service, kind_of: Chef::Resource, required: true
attribute :vhost, kind_of: [TrueClass, FalseClass], default: false
attribute :domain, kind_of: String
attribute :aliases, kind_of: Array, default: []

attr_accessor :id, :mysql_connection

attr_writer :domain

#
# Cookbook Name:: phpmyadmin
# Attributes:: default
#

default['phpmyadmin']['instances'] = []

default['phpmyadmin']['repo'] = 'https://github.com/phpmyadmin/phpmyadmin.git'
default['phpmyadmin']['revision'] = 'RELEASE_4_2_5'
default['phpmyadmin']['sql'] = 'examples/create_tables.sql'

#
# Cookbook Name:: phpmyadmin
# Attributes:: default
#

default['phpmyadmin']['instances'] = {}

default['phpmyadmin']['post_max_size'] = '200M'
default['phpmyadmin']['upload_max_filesize'] = '200M'

default['phpmyadmin']['php_options'] = {
  'php_value[post_max_size]' => node['phpmyadmin']['post_max_size'],
  'php_value[upload_max_filesize]' => node['phpmyadmin']['upload_max_filesize']
}

default['phpmyadmin']['mirror'] = 'https://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin'
default['phpmyadmin']['version'] = '4.4.4'
default['phpmyadmin']['checksum'] = '2e21f61b2b7ad626a29867718b7ab2b0007c5841b543a28cd377371f68c761c4'
default['phpmyadmin']['sql'] = 'sql/create_tables.sql'
default['phpmyadmin']['extensions'] = %w(zip)
default['phpmyadmin']['shared'] = %w(upload save tmp)
default['phpmyadmin']['hide'] = %w(information_schema mysql performance_schema phpmyadmin_.*)
default['phpmyadmin']['control_tables'] = {
  bookmarktable: 'pma__bookmark',
  relation: 'pma__relation',
  table_info: 'pma__table_info',
  table_coords: 'pma__table_coords',
  pdf_pages: 'pma__pdf_pages',
  column_info: 'pma__column_info',
  history: 'pma__history',
  table_uiprefs: 'pma__table_uiprefs',
  tracking: 'pma__tracking',
  designer_coords: 'pma__designer_coords',
  userconfig: 'pma__userconfig',
  recent: 'pma__recent',
  favorite: 'pma__favorite',
  users: 'pma__users',
  usergroups: 'pma__usergroups',
  navigationhiding: 'pma__navigationhiding',
  savedsearches: 'pma__savedsearches',
}

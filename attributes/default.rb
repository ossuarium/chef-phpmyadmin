#
# Cookbook Name:: phpmyadmin
# Attributes:: default
#

default['phpmyadmin']['instances'] = {}

default['phpmyadmin']['mirror'] = 'http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin'
default['phpmyadmin']['version'] = '4.2.5'
default['phpmyadmin']['checksum'] = '6eaa6f4fd78f8092ecd8df4da10fb0c3f0bd09c390c8c7262d369ae12faa9434'
default['phpmyadmin']['sql'] = 'examples/create_tables.sql'
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

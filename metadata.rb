name             'phpmyadmin'
maintainer       'OurTownRentals.com'
maintainer_email 'evan@ourtownrentals.com'
license          'All rights reserved'
description      'Configures phpMyAdmin.'
version          '0.0.0'

recipe 'phpmyadmin::default', 'Configures phpMyAdmin.'

depends 'apache2', '~> 3.0.1'
depends 'core', '~> 0.0.0'
depends 'database', '~> 4.0.6'
depends 'mysql2_chef_gem', '~> 1.0.1'
depends 'tar', '~> 0.6.0'

provides 'service[phpmyadmin]'

attribute 'phpmyadmin/instances',
          display_name: 'Instances',
          description: 'Instances to create on the node.',
          type: 'hash',
          recipes: ['phpmyadmin::default'],
          default: {}

attribute 'phpmyadmin/post_max_size',
          display_name: 'POST max size',
          description: 'Sets the PHP post_max_size.',
          type: 'string',
          recipes: ['phpmyadmin::default'],
          default: '200M'

attribute 'phpmyadmin/upload_max_filesize',
          display_name: 'Upload max filesize',
          description: 'Sets the PHP upload_max_filesize.',
          type: 'string',
          recipes: ['phpmyadmin::default'],
          default: '200M'

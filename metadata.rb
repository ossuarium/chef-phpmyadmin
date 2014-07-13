name             'phpmyadmin'
maintainer       'OurTownRentals.com'
maintainer_email 'evan@ourtownrentals.com'
license          'All rights reserved'
description      'Configures phpMyAdmin.'
version          '0.0.0'

recipe 'phpmyadmin::default', 'Configures phpMyAdmin.'

depends 'core', '~> 0.0.0'
depends 'tar', '~> 0.4.0'
depends 'mysql', '~> 5.3.6'
depends 'php', '~> 1.4.7'

provides 'service[phpmyadmin]'

attribute 'phpmyadmin/instances',
          display_name: 'Instances',
          description: %q{Instances to create on the node.},
          type: 'hash',
          recipes: ['phpmyadmin::default'],
          default: {}

attribute 'phpmyadmin/post_max_size',
          display_name: 'POST max size',
          description: %q{Sets the PHP post_max_size.},
          type: 'string',
          recipes: ['phpmyadmin::default'],
          default: '200M'

attribute 'phpmyadmin/upload_max_filesize',
          display_name: 'Upload max filesize',
          description: %q{Sets the PHP upload_max_filesize.},
          type: 'string',
          recipes: ['phpmyadmin::default'],
          default: '200M'

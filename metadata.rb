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

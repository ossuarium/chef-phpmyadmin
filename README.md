# phpmyadmin

[![All rights reserved](http://img.shields.io/badge/license-All_rights_reserved-red.svg?style=flat)](./LICENSE.txt)

## Description

Configures phpMyAdmin.

## Requirements

### Cookbooks:

* core (~> 0.0.0)
* tar (~> 0.4.0)

## Attributes

Attribute | Default | Description | Choices
----------|---------|-------------|--------
`node['phpmyadmin']['instances']` | `{}` | Instances to create on the node. |
`node['phpmyadmin']['post_max_size']` | `"200M"` | Sets the PHP post_max_size. |
`node['phpmyadmin']['upload_max_filesize']` | `"200M"` | Sets the PHP upload_max_filesize. |

## Recipes

* phpmyadmin::default - Configures phpMyAdmin.

## Resources

* [phpmyadmin](#phpmyadmin)

### phpmyadmin



#### Actions

- create: creates the instance. Default action.
- delete: deletes the instance.
- destroy: deletes the instance, database, and shared directory.

#### Attribute Parameters

- name: the name of the instance.
- service: the core_service to use for the instance.
- ssl: whether to use ssl. Defaults to <code>false</code>.
- vhost: whether to setup a vhost for this instance. Overrides global alias. Defaults to <code>false</code>.
- alias_path: the web server global alias path for accessing the admin. Defaults to <code>"phpmyadmin"</code>.
- domain: the domain to use for the web server.
- aliases: the domain aliases to use for the web server. Defaults to <code>[]</code>.

## Development and Testing

### Source Code

The [phpmyadmin source](https://github.com/ourtownrentals/chef-phpmyadmin)
is hosted on GitHub.
To clone the project run

````bash
$ git clone https://github.com/ourtownrentals/chef-phpmyadmin.git
````

### Rake

Run `rake -T` to see all Rake tasks.

````
rake all                          # Run all tasks
rake doc                          # Build documentation
rake foodcritic                   # Lint Chef cookbooks
rake kitchen:all                  # Run all test instances
rake kitchen:default-centos-65    # Run default-centos-65 test instance
rake kitchen:default-ubuntu-1404  # Run default-ubuntu-1404 test instance
rake readme                       # Generate README.md from _README.md.erb
rake rubocop                      # Run RuboCop
rake rubocop:auto_correct         # Auto-correct RuboCop offenses
rake spec                         # Run RSpec code examples
rake test                         # Run kitchen integration tests
rake yard                         # Generate YARD Documentation
````

### Thor

Run `thor -T` to see all Thor tasks.

### Guard

Guard tasks have been separated into the following groups:

- `doc`
- `lint`
- `unit`
- `integration`

By default, Guard will generate documentation, lint, and run unit tests.
The integration group must be selected manually with `guard -g integration`.

## Contributing

Please submit and comment on bug reports and feature requests.

To submit a patch:

1. Fork it (https://github.com/ourtownrentals/chef-phpmyadmin/fork).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Make changes. Write and run tests.
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create a new Pull Request.

## License

Copyright © 2014 OurTownRentals.com

## Warranty

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.

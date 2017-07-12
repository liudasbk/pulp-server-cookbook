# pulp_server

This cookbook installs and configures pulp server and provides pulp repository
resources.

The cookbook follows the same installation procedure as described in Pulp documentation. However, some aspects can be adjusted using attributes (for example skipping mongodb or qpid installation if you doing that with other cookbooks).

More information:
- [Pulp project page](http://pulpproject.org/)
- [Pulp documentation](https://docs.pulpproject.org/user-guide)

## Requirements

### Platforms

- CentOS 7

## Attributes

- `node['pulp_server']['version']` - Specifies Pulp server version. It is used to configure pulp yum repository.
- `node['pulp_server']['configure_repos']` - If true, setup yum repository for pulp server installation. Default: true.
- `node['pulp_server']['install_baseurl']` - baseurl to use in pulp server installation repository configuration. Default: `https://repos.fedorapeople.org/repos/pulp/pulp/stable/2.11/$releasever/$basearch/`.
- `node['pulp_server']['install_gpgkey']` - gpgkey to use in pulp server installation repository configuration. Default: `https://repos.fedorapeople.org/repos/pulp/pulp/GPG-RPM-KEY-pulp-2`.
- `node['pulp_server']['configure_epel']` - If true, setup yum repository for EPEL, this is required for mongodb, qpid and other dependencies. Set to false if repository is configured by other means (for example epel cookbook). Default: true.
- `node['pulp_server']['epel_mirrorlist']` - mirrorlist to use in EPEL repository configuration. Defalt: `http://mirrors.fedoraproject.org/mirrorlist?repo=epel-7&arch=$basearch`
- `node['pulp_server']['epel_gpgkey']` - gpgkey to use in EPEL repository configuration. Default: `http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7`.
- `node['pulp_server']['install_mongodb']` - If true, installs and configures mongodb. Repository for mongodb should be configured by other means if `node['pulp_server']['configure_epel']` is set to false. Default: true.
- `node['pulp_server']['install_qpid']` - If true, installs and configures qpid. Repository for qpid should be configured by other means if `node['pulp_server']['configure_epel']` is set to false. Default: true.
- `node['pulp_server']['enabled_modules']` - An array of pulp modules to install. Valid values are `rpm`, `puppet` and `docker`. Default: `%w(rpm)`

### Server config

- `node['pulp_server']['config']` - A hash of pulp server options. Valid sections are: `database`, `server`, `authentication`, `security`, `consumer_history`, `data_reaping`, `ldap`, `oauth`, `messaging`, `tasks`, `email`, `lazy` and `profiling`. For more please see [https://github.com/pulp/pulp/blob/master/server/etc/pulp/server.conf](https://github.com/pulp/pulp/blob/master/server/etc/pulp/server.conf)

### Admin client config

- `node['pulp_server']['install_admin_client']` - If true, installs and configures pulp admin client with all required extensions. Default: true.
- `node['pulp_server']['admin']` - A hash of pulp admin client options. Valid sections are `server`, `client`, `filesystem` and `output`. For more please see [https://github.com/pulp/pulp/blob/master/client_admin/etc/pulp/admin/admin.conf](https://github.com/pulp/pulp/blob/master/client_admin/etc/pulp/admin/admin.conf)

## Recipes

### admin

This recipe installs and configures pulp admin client. If additional modules are enabled admin extensions are installed as well.

### default

This is the main recipe which should be included in a run list to have pulp server installed. It includes other recipes depending on following attributes:

- `node['pulp_server']['install_admin_client']`
- `node['pulp_server']['install_mongodb']`
- `node['pulp_server']['install_qpid']`
- `node['pulp_server']['configure_repos']`

If you have other means to configure repositories and/or install/configure mongodb, qpid, set required attribute to false.

### mongodb

This recipe installs and starts mongodb server. The recipe does not configure repository from which mongodb is installed. This can be done by setting `node['pulp_server']['configure_epel']` to true of by other cookbooks (for example epel cookbook).

The recipe is included from default if `node['pulp_server']['install_mongodb']` is set to true.

### qpid

This recipe installs and start qpid. As with mongodb, this recipe does not configure installation repository. Repository can be enabled by setting `node['pulp_server']['configure_epel']` to true or by other cookbooks (for example epel).

The recipe is included from default if `node['pulp_server']['install_qpid']` is set to true.

### repos

This recipe configures pulp server and epel YUM repositories. EPEL repository configuration can be skipped by setting `node['pulp_server']['configure_epel']` to false (for example if you have epel cookbook in your run list).

The recipe is included from default if `node['pulp_server']['configure_repos']` is set to true.

## License & Authors
```
# The MIT License (MIT)
#
# Copyright:: 2017, Liudas Baksys
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
```

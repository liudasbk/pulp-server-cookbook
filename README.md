# pulp_server

[![Build Status](https://travis-ci.org/liudasbk/pulp-server-cookbook.svg?branch=master)](https://travis-ci.org/liudasbk/pulp-server-cookbook) [![Cookbook Version](https://img.shields.io/cookbook/v/pulp_server.svg)](https://supermarket.chef.io/cookbooks/pulp_server)

This cookbook installs and configures pulp server and provides pulp repository
resources.

The cookbook follows the same installation procedure as described in Pulp documentation. However, some aspects can be adjusted using attributes (for example skipping mongodb or qpid installation if you doing that with other cookbooks).

More information:
- [Pulp project page](http://pulpproject.org/)
- [Pulp documentation](https://docs.pulpproject.org/user-guide)

## Requirements

### Platforms

- CentOS 7

### Chef

- Chef 12.8+

## Attributes

- `node['pulp_server']['version']` - Specifies Pulp server version. It is used to configure pulp yum repository. Default: `2.13`.
- `node['pulp_server']['configure_repos']` - If true, setup yum repository for pulp server installation. Default: true.
- `node['pulp_server']['install_baseurl']` - baseurl to use in pulp server installation repository configuration. Default: `https://repos.fedorapeople.org/repos/pulp/pulp/stable/2.11/$releasever/$basearch/`.
- `node['pulp_server']['install_gpgkey']` - gpgkey to use in pulp server installation repository configuration. Default: `https://repos.fedorapeople.org/repos/pulp/pulp/GPG-RPM-KEY-pulp-2`.
- `node['pulp_server']['configure_epel']` - If true, setup yum repository for EPEL, this is required for mongodb, qpid and other dependencies. Set to false if repository is configured by other means (for example epel cookbook). Default: true.
- `node['pulp_server']['epel_mirrorlist']` - mirrorlist to use in EPEL repository configuration. Defalt: `http://mirrors.fedoraproject.org/mirrorlist?repo=epel-7&arch=$basearch`
- `node['pulp_server']['epel_gpgkey']` - gpgkey to use in EPEL repository configuration. Default: `http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7`.
- `node['pulp_server']['install_mongodb']` - If true, installs and configures mongodb. Repository for mongodb should be configured by other means if `node['pulp_server']['configure_epel']` is set to false. Default: true.
- `node['pulp_server']['install_qpid']` - If true, installs and configures qpid. Repository for qpid should be configured by other means if `node['pulp_server']['configure_epel']` is set to false. Default: true.
- `node['pulp_server']['enabled_modules']` - An array of pulp modules to install. Valid values are `rpm`, `puppet` and `docker`. Default: `%w(rpm)`

### Server config

- `node['pulp_server']['config']` - A hash of pulp server options. Valid sections are: `database`, `server`, `authentication`, `security`, `consumer_history`, `data_reaping`, `ldap`, `oauth`, `messaging`, `tasks`, `email`, `lazy` and `profiling`. For more please see [https://github.com/pulp/pulp/blob/master/server/etc/pulp/server.conf](https://github.com/pulp/pulp/blob/master/server/etc/pulp/server.conf)

### Admin client config

- `node['pulp_server']['install_admin_client']` - If true, installs and configures pulp admin client with all required extensions. Default: true.
- `node['pulp_server']['admin']` - A hash of pulp admin client options. Valid sections are `server`, `client`, `filesystem` and `output`. For more please see [https://github.com/pulp/pulp/blob/master/client_admin/etc/pulp/admin/admin.conf](https://github.com/pulp/pulp/blob/master/client_admin/etc/pulp/admin/admin.conf)

## Resources

### pulp_rpm_repo

The `pulp_rpm_repo` resource setups RPM repository on pulp server.

#### Actions

- `:create` - Creates and/or updates a RPM repository on pulp server
- `:delete` - Deletes a RPM repository on pulp server
- `:sync` - Runs sync for a repository
- `:publish` - Runs publish for a repository

#### Properties

##### Pulp server

The pulp server properties are used to define Pulp server on which repository action takes place.

- `pulp_server` - Hostname of Pulp server. This is used to make API calls. Default: `localhost`.
- `pulp_user` - Username to use for Pulp API. The user must have get, put and post privileges to repositories. Default: `admin`.
- `pulp_password` - Password for user. Default: `admin`.
- `pulp_ca_cert` - Path to CA certificate for Pulp server certificate verification. Default: `nil`.
- `pulp_cert_verify` - If set to False certificate verification is skipped. Default: `true`.

##### Repository

The repository properties defines various settings of Pulp rpm repository managed by this resource. Please refer to pulp rpm plugin documentation for more details:
 [https://docs.pulpproject.org/plugins/pulp_rpm/tech-reference/yum-plugins.html](https://docs.pulpproject.org/plugins/pulp_rpm/tech-reference/yum-plugins.html)


- `display_name` - Short description of a repository.
- `description` - Detailed description of a repository.
- `feed` - URL of upstream repository to sync packages from.
- `skip` - List of content type to skip.
- `require_signature` - If set to `true` imported packages must be signed.
- `allowed_keys` - Comma-separated list of allowed signature key IDs that imported packages can be signed with.
- `ssl_ca_cert` - CA certificate for upstream repository certificate check.
- `ssl_validation` - If set to true validates upstream repository certificate. Default: `true`.
- `ssl_client_cert` - Client certificate to use for upstream repository.
- `ssl_client_key` - Client certificate's key.
- `relative_url` - Relative path at which repository is served. Default `<repository_name>`.
- `max_downloads` - Number of thread used for repository sync.
- `max_speed` - Maximum download speed bytes/sec.
- `remove_missing` - If set to true, old RPMs are removed during sync.
- `retain_old_count` - Number of old versions to keep in a repository.
- `download_policy` - `on_demand` - downloads when client requests package, `background` - downloads after sync is completed. Default: `immediate`.
- `http` - If set to true serves content on HTTP protocol. Default: `true`.
- `https` - If set to true serves content on HTTPS protocol. Default: `false`.
- `gpgkey` - GPG key used to sign RPM packages in a repository.
- `generate_sqlite` - If set to `true` sqlite database is generated for a repository.
- `repoview` - If set to `true` static repoview HTML files are generated for a repository.
- `updateinfo_checksum_type` - Checksum type to use in updateinfo.xml.

#### Examples

Create a repository named `pulp-2.11-stable` with upstream URL set.

```ruby
pulp_rpm_repo 'pulp-2.11-stable' do
  description 'Pulp 2.11 Production Releases'
  feed 'https://repos.fedorapeople.org/repos/pulp/pulp/stable/'
end
```

Create a repository named `devel`, sync and publish the repository.

```ruby
pulp_rpm_repo 'devel' do
  description 'Latest packages'
  feed 'https://initech.local/devel'
  action [:create, :sync, :publish]
end
```

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

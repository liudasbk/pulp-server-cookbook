#
# Cookbook:: pulp_server
# Recipe:: default
#
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

include_recipe 'pulp_server::repos' if node['pulp_server']['configure_repos']
include_recipe 'pulp_server::mongodb' if node['pulp_server']['install_mongodb']
include_recipe 'pulp_server::qpid' if node['pulp_server']['install_qpid']

# server packages
package node['pulp_server']['server_packages']

# install and configure admin client
include_recipe 'pulp_server::admin' \
  if node['pulp_server']['install_admin_client']

execute 'pulp-manage-db' do
  command 'su apache -s /bin/bash -c "/usr/bin/pulp-manage-db"'
  not_if 'su apache -s /bin/bash -c "/usr/bin/pulp-manage-db --dry-run"'
  notifies :restart, 'service[httpd]', :delayed
end

execute 'pulp-gen-ca-certificate' do
  command 'pulp-gen-ca-certificate'
  not_if { ::File.exist? '/etc/pki/pulp/ca.crt' }
end

directory '/etc/pulp' do
  owner 'root'
  group 'root'
  mode 0o0755
end

template '/etc/pulp/server.conf' do
  source 'server.conf.erb'
  owner 'root'
  group 'apache'
  mode 0o0640
  notifies :restart, 'service[httpd]', :delayed
end

%w[pulp_workers pulp_celerybeat pulp_resource_manager].each do |svc|
  service svc do
    action %i[start enable]
  end
end

service 'httpd' do
  action %i[start enable]
end

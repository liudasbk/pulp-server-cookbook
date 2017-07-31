
# create CA cert

execute 'ca_key' do
  command 'openssl genrsa -out /etc/pki/tls/private/ca.key'
  not_if { ::File.exist? '/etc/pki/tls/private/ca.key' }
end

execute 'ca_cert' do
  command 'openssl req -new -x509 -days 10 -key /etc/pki/tls/private/ca.key ' \
    '-subj "/C=US/ST=Texas/L=Austin/O=Initech/CN=Dummy Root CA" ' \
    '-out /etc/pki/tls/certs/ca.crt'
  not_if { ::File.exist? '/etc/pki/tls/certs/ca.crt' }
end

# create host cert

execute 'host_key' do
  command "openssl genrsa -out /etc/pki/tls/private/#{node['fqdn']}.key"
  not_if { ::File.exist? "/etc/pki/tls/private/#{node['fqdn']}.key" }
end

execute 'host_req' do
  command 'openssl req -new ' \
    "-key /etc/pki/tls/private/#{node['fqdn']}.key " \
    "-subj \"/C=US/ST=Texas/L=Austin/O=Initech/CN=#{node['fqdn']}\" " \
    "-out /etc/pki/tls/certs/#{node['fqdn']}.csr"
  not_if { ::File.exist? "/etc/pki/tls/certs/#{node['fqdn']}.csr" }
end

execute 'host_cert' do
  command 'openssl x509 -req -days 10 ' \
    "-in /etc/pki/tls/certs/#{node['fqdn']}.csr " \
    '-CA /etc/pki/tls/certs/ca.crt ' \
    '-CAkey /etc/pki/tls/private/ca.key ' \
    '-set_serial 01 ' \
    "-out /etc/pki/tls/certs/#{node['fqdn']}.crt"
  not_if { ::File.exist? "/etc/pki/tls/certs/#{node['fqdn']}.crt" }
end

link '/etc/pki/tls/certs/localhost.crt' do
  to "/etc/pki/tls/certs/#{node['fqdn']}.crt"
end

link '/etc/pki/tls/private/localhost.key' do
  to "/etc/pki/tls/private/#{node['fqdn']}.key"
end

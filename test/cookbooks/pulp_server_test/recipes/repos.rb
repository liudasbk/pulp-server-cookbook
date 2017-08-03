
pulp_rpm_repo 'test' do
  pulp_cert_verify false
  display_name 'TPS repository'
  description 'This repository is to keep all TPS reports'
  feed 'https://intech.local/pulp/tps/'
  http true
  https true
end

pulp_rpm_repo 'test-1' do
  pulp_server node['fqdn']
  pulp_ca_cert '/etc/pki/tls/certs/ca.crt'
  display_name 'Param test repository'
  description 'This repository is used to test if parameters are set correctly'
  feed 'https://localhost/'
  skip %w[item1 item2]
  require_signature false
  allowed_keys %w[key1key1 key2key2]
  ssl_ca_cert 'ca_certificate'
  ssl_validation true
  ssl_client_cert 'certificate'
  ssl_client_key 'key'
  relative_url 'repositories/test1'
  max_downloads 10
  max_speed 10_000
  remove_missing false
  retain_old_count 1
  download_policy 'immediate'
  http false
  https true
  checksum_type 'sha1'
  gpgkey 'gpgkey'
  generate_sqlite true
  repoview true
  updateinfo_checksum_type true
end

pulp_rpm_repo 'pulp-2.11-stable' do
  pulp_server node['fqdn']
  pulp_ca_cert '/etc/pki/tls/certs/ca.crt'
  display_name 'Pulp 2.11 Production Releases'
  feed 'https://repos.fedorapeople.org/repos/pulp/pulp/stable/'
  http true
  https true
  action %i[create sync publish]
end

pulp_rpm_repo 'test' do
  pulp_cert_verify false
  action :delete
end


pulp_rpm_repo 'test' do
  display_name 'TPS repository'
  description 'This repository is to keep all TPS reports'
  feed 'https://intech.local/pulp/tps/'
  http true
  https true
end

pulp_rpm_repo 'test-1' do
  display_name 'Param test repository'
  description 'This repository is used to test if parameters are set correctly'
  feed 'https://localhost/'
  skip %w[item1 item2]
  require_signature false
  allowed_keys %w[key1key1 key2key2]
end

pulp_rpm_repo 'pulp-2.11-stable' do
  display_name 'Pulp 2.11 Production Releases'
  feed 'https://repos.fedorapeople.org/repos/pulp/pulp/stable/'
  http true
  https true
  action %i[create sync publish]
end

pulp_rpm_repo 'test' do
  action :delete
end

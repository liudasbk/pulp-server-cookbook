
describe command('pulp-admin rpm repo list --repo-id test-1 --details') do
  {
    'Display Name' => 'Param test repository',
    'Allowed Keys' => 'key1key1, key2key2',
    'Require Signature' => 'False',
    'Feed' => 'https://localhost/',
    'Skip' => 'item1, item2'
  }.each do |param, value|
    its('stdout') { should match(/^\s*#{param}\:\s+#{value}$/) }
  end
end

describe command('pulp-admin rpm repo list --repo-id test') do
  its('stdout') do
    should match(/The following resource\(s\) could not be found\:/)
  end
  its('exit_status') { should eq 65 }
end

describe command('pulp-admin tasks list -a ' \
  '| awk \'BEGIN { RS=""; FS="\n" }{ print $1","$2 }\'') do
  its('stdout') do
    should match(/Operations\:\s+sync,Resources\:\s+pulp-2.11-stable/)
  end
  its('stdout') do
    should match(/Operations\:\s+publish,Resources\:\s+pulp-2.11-stable/)
  end
end

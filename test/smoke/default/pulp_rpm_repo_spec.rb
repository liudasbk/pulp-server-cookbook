
# rubocop:disable BlockLength
describe command('pulp-admin -u admin -p admin ' \
  'rpm repo list --repo-id test-1 --details') do
  {
    'Display Name' => 'Param test repository',
    'Description' => 'This repository is used to test if parameters are set',
    'Feed' => 'https://localhost/',
    'Skip' => 'item1, item2',
    'Require Signature' => 'False',
    'Allowed Keys' => 'key1key1, key2key2',
    'SSL CA Cert' => 'ca_certificate',
    'SSL Client Cert' => 'certificate',
    'SSL Client Key' => 'key',
    'SSL Validation' => 'True',
    'Relative URL' => 'repositories/test1',
    'Max Downloads' => '10',
    'Max Speed' => '10000',
    'Remove Missing' => 'False',
    'Retain Old Count' => '1',
    'Download Policy' => 'immediate',
    'Http' => 'False',
    'Https' => 'True',
    'Checksum Type' => 'sha1',
    'Gpgkey' => 'gpgkey',
    'Generate Sqlite' => 'True',
    'Repoview' => 'True',
    'Updateinfo Checksum Type' => 'True'
  }.each do |param, value|
    its('stdout') { should match(/^\s*#{param}\:\s+#{value}$/) }
  end
end

describe command('pulp-admin -u admin -p admin rpm repo list --repo-id test') do
  its('stdout') do
    should match(/The following resource\(s\) could not be found\:/)
  end
  its('exit_status') { should eq 65 }
end

describe command('pulp-admin -u admin -p admin tasks list -a ' \
  '| awk \'BEGIN { RS=""; FS="\n" }{ print $1","$2 }\'') do
  its('stdout') do
    should match(/Operations\:\s+sync,Resources\:\s+pulp-2.11-stable/)
  end
  its('stdout') do
    should match(/Operations\:\s+publish,Resources\:\s+pulp-2.11-stable/)
  end
end

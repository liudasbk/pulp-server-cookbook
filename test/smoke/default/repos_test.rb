# # encoding: utf-8

# Inspec test for recipe pulp-server-cookbook::repos

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/etc/yum.repos.d/pulp-2.13-stable.repo') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0644' }
end

describe file('/etc/yum.repos.d/epel.repo') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0644' }
end

describe command('yum repolist --disablerepo=*' \
                 '--enablerepo=pulp-2.13-stable') do
  its('exit_status') { should eq 0 }
end

describe command('yum repolist --disablerepo=* --enablerepo=epel') do
  its('exit_status') { should eq 0 }
end

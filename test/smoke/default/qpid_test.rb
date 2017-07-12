# # encoding: utf-8

# Inspec test for recipe pulp-server-cookbook::qpid

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe service('qpidd') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

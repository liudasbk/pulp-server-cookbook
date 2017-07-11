# # encoding: utf-8

# Inspec test for recipe pulp_server::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

%w[httpd pulp_workers pulp_celerybeat pulp_resource_manager].each do |svc|
  describe service(svc) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end


default['pulp_server']['version'] = '2.13'

# Pulp install repository
default['pulp_server']['configure_repos'] = true
default['pulp_server']['install_baseurl'] = \
  'https://repos.fedorapeople.org/repos/pulp/pulp/stable/' \
  "#{node['pulp_server']['version']}/$releasever/$basearch/"
default['pulp_server']['install_gpgkey'] = \
  'https://repos.fedorapeople.org/repos/pulp/pulp/GPG-RPM-KEY-pulp-2'

# EPEL repository
default['pulp_server']['configure_epel'] = true
default['pulp_server']['epel_mirrorlist'] = \
  'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-7&arch=$basearch'
default['pulp_server']['epel_gpgkey'] = \
  'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'

# set to false if mongodb and/or qpid is installed by external tools cookbooks
default['pulp_server']['install_mongodb'] = true
default['pulp_server']['install_qpid'] = true

# admin client, also installs admin extensions for each enabled content type
default['pulp_server']['install_admin_client'] = true

# enabled content types. Valid values: rpm, puppet, docker (not supported)
default['pulp_server']['enabled_modules'] = %w[rpm]

default['pulp_server']['server_packages'] = \
  %w[pulp-server] + \
  node['pulp_server']['enabled_modules'].map { |name| "pulp-#{name}-plugins" }

default['pulp_server']['admin_packages'] = \
  %w[pulp-admin-client] + \
  node['pulp_server']['enabled_modules'] \
  .map { |name| "pulp-#{name}-admin-extensions" }

##
## server configuration
##
default['pulp_server']['config']['database'] = {
  'name' => 'pulp_database',
  'seeds' => 'localhost',
  'ssl' => false,
  'ssl_keyfile' => '',
  'ssl_certfile' => '',
  'verify_ssl' => true,
  'ca_path' => '/etc/pki/tls/certs/ca-bundle.crt',
  'unsafe_autoretry' => false,
  'write_concern' => 'majority'
}
default['pulp_server']['config']['server'] = {
  'server_name' => node['hostname'],
  'key_url' => '/pulp/gpg',
  'ks_url' => '/pulp/ks',
  'default_login' => 'admin',
  'default_password' => 'admin',
  'debugging_mode' => false,
  'log_level' => 'INFO',
  'working_directory' => '/var/cache/pulp'
}
default['pulp_server']['config']['authentication'] = {
  'rsa_key' => '/etc/pki/pulp/rsa.key',
  'rsa_pub' => '/etc/pki/pulp/rsa_pub.key'
}
default['pulp_server']['config']['security'] = {
  'user_cert_expiration' => 7,
  'consumer_cert_expiration' => 3650,
  'serial_number_path' => '/var/lib/pulp/sn.dat'
}
default['pulp_server']['config']['consumer_history'] = {
  'lifetime' => 180
}
default['pulp_server']['config']['data_reaping'] = {
  'reaper_interval' => 0.25,
  'consumer_history' => 60,
  'repo_sync_history' => 60,
  'repo_publish_history' => 60,
  'repo_group_publish_history' => 60,
  'task_status_history' => 7,
  'task_result_history' => 3
}
default['pulp_server']['config']['messaging'] = {
  'url' => 'tcp://localhost:5672',
  'transport' => 'qpid',
  'auth_enabled' => 'true',
  'cacert' => '/etc/pki/qpid/ca/ca.crt',
  'clientcert' =>  '/etc/pki/qpid/client/client.pem',
  'topic_exchange' => 'amq.topic',
  'event_notifications_enabled' => false,
  'event_notification_url' => 'qpid'
}
default['pulp_server']['config']['tasks'] = {
  'broker_url' => 'qpid://localhost/',
  'celery_require_ssl' => false,
  'cacert' => '/etc/pki/pulp/qpid/ca.crt',
  'keyfile' => '/etc/pki/pulp/qpid/client.crt',
  'certfile' => '/etc/pki/pulp/qpid/client.crt',
  'login_method' => ''
}

##
## admin client configuration
##
default['pulp_server']['admin']['server'] = {
  'host' => node['fqdn'],
  'port' => 443,
  'api_prefix' => '/pulp/api',
  'verify_ssl' => true,
  'ca_path' => '/etc/pki/tls/certs/ca-bundle.crt',
  'upload_chunk_size' => 1_048_576
}
default['pulp_server']['admin']['client'] = {
  'role' => 'admin'
}
default['pulp_server']['admin']['filesystem'] = {
  'extensions_dir' => '/usr/lib/pulp/admin/extensions',
  'id_cert_dir' => '~/.pulp',
  'id_cert_filename' => 'user-cert.pem',
  'upload_working_dir' => '~/.pulp/uploads'
}
default['pulp_server']['admin']['output'] = {
  'poll_frequency_in_seconds' => 1,
  'enable_color' => true,
  'wrap_to_terminal' => false,
  'wrap_width' => 80
}

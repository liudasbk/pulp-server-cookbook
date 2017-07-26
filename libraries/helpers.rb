
module PulpServerCookbook
  module Helpers

    def prop_values(names)
      values = {}
      (new_resource.methods & names).each do |name|
        values[name] = new_resource.method(name).call \
          if new_resource.method(name).call != nil
      end
      values.size > 0 ? values : nil
    end

    def importer_config
      # TODO: figure out how to pass vadildate parameter
      prop_values %i(
        feed
        ssl_validation
        ssl_ca_cert
        ssl_client_cert
        ssl_client_key
        proxy_host
        proxy_username
        proxy_password
        basic_auth_username
        basic_auth_password
        query_auth_token
        max_speed
        max_downloads
        remove_missing
        retain_old_count
        skip
        checksum_type
        num_retries
        copy_children
        download_policy
        require_signature
        allowed_keys
      )
    end

    def distributor_configs
      conf = prop_values %i(
        http
        https
        relative_url
        protected
        auth_cert
        auth_ca
        https_ca
        gpgkey
        generate_sqlite
        repoview
        checksum_type
        updateinfo_checksum_type
        skip
        force_full
      )
      conf.nil? ? nil : { 'yum_distributor_config' => conf }
    end

    def export_distributor_config
      conf = prop_values %i(
        http
        https
        relative_url
        generate_sqlite
        skip
        checksum_type
        updateinfo_checksum_type
      )
      conf.nil? ? nil : { 'export_distributor_config' => conf }
    end

    def repo_config
      prop_values %i(description display_name)
    end

    # quick and dirty
    def api_request(path, method, query = nil)
      client = HTTPClient.new(:force_basic_auth => true)

      uri = "https://#{new_resource.host}/pulp/api/v2/#{path}"

      client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      client.set_auth nil, new_resource.username, new_resource.password \
        if new_resource.username && new_resource.password

      res = if method == 'put'
              client.put URI.parse(uri), query.to_json
            elsif method == 'post'
              client.post URI.parse(uri), query.to_json
            elsif method == 'delete'
              client.delete URI.parse(uri)
            else
              client.get URI.parse(uri)
            end

      Chef::Log.warn(JSON.pretty_generate(res.body))
      JSON.parse(res.body)
    end

    def get_repo
      api_request "repositories/#{new_resource.repo_id}/"
    end

    def create_repo
      api_request "repositories/", 'post', \
        {
          :id => new_resource.repo_id,
          :notes => {'_repo-type' => 'rpm-repo'},
          :importer_type_id => 'yum_importer',
          :importer_config => importer_config,
          :distributors => [
            {
              :distributor_id => 'yum_distributor',
              :distributor_type_id => 'yum_distributor',
              :distributor_config => distributor_configs['yum_distributor_config']
            },
            {
              :distributor_id => 'export_distributor',
              :distributor_type_id => 'export_distributor',
              :distributor_config => export_distributor_config['export_distributor_config']
            }
          ]
        }.merge(repo_config)
    end

    def update_repo
      api_request "repositories/#{new_resource.repo_id}/", 'put', \
        {
          :delta => repo_config,
          :importer_config => importer_config,
          :distributor_configs => distributor_configs
        }.select { |_, v| !v.nil? }
    end

    def delete_repo
      api_request "repositories/#{new_resource.repo_id}/", 'delete'
    end

    def sync_repo
      api_request "repositories/#{new_resource.repo_id}/actions/sync/", \
        'post', {}
    end

    def publish_repo
      api_request "repositories/#{new_resource.repo_id}/actions/publish/", \
        'post', { :id => 'yum_distributor' }
    end
  end
end

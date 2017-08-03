#
# Cookbook:: pulp_server
# Library:: helpers
#
# The MIT License (MIT)
#
# Copyright:: 2017, Liudas Baksys
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# rubocop:disable ModuleLength
module PulpServerCookbook
  # Helper module implements various methods to interact with a pulp server
  module Helpers
    def prop_values(names)
      values = {}
      (new_resource.methods & names).each do |name|
        values[name] = new_resource.method(name).call if property_is_set? name
      end
      values
    end

    # rubocop:disable MethodLength
    def importer_config
      # TODO: figure out how to pass vadildate parameter
      prop_values %i[
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
      ]
    end

    def yum_dist_config
      prop_values %i[
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
      ]
    end

    def export_dist_config
      prop_values %i[
        http
        https
        relative_url
        generate_sqlite
        skip
        checksum_type
        updateinfo_checksum_type
      ]
    end

    def repo_config
      prop_values %i[description display_name]
    end

    # rubocop:disable AbcSize
    # rubocop:disable CyclomaticComplexity
    # rubocop:disable PerceivedComplexity
    def api_request(path, method, query = nil)
      client = HTTPClient.new(force_basic_auth: true)

      uri = "https://#{new_resource.pulp_server}/pulp/api/v2/#{path}"

      client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE \
        unless new_resource.pulp_cert_verify
      client.ssl_config.set_trust_ca(new_resource.pulp_ca_cert) \
        if property_is_set? :pulp_ca_cert
      client.set_auth nil, new_resource.pulp_user, new_resource.pulp_password \
        if new_resource.pulp_user && new_resource.pulp_password

      res = case method
            when 'put'
              client.put URI.parse(uri), query.to_json
            when 'post'
              client.post URI.parse(uri), query.to_json
            when 'delete'
              client.delete URI.parse(uri)
            else
              client.get URI.parse(uri)
            end

      begin
        msg = JSON.parse(res.body)
        if msg['error']
          Chef::Log.error("Failed running action for #{new_resource}: " \
                          + msg['error']['description'])
          raise msg['error']['description']
        end
        msg
      rescue JSON::ParserError => e
        Chef::Log.error("Failed parsing pulp server response:\n#{res.body}")
        raise e.message
      end
    end

    def create_repo
      api_request 'repositories/', 'post', \
                  {
                    id: new_resource.repo_id,
                    notes: { '_repo-type' => 'rpm-repo' },
                    importer_type_id: 'yum_importer',
                    importer_config: importer_config,
                    distributors: [
                      {
                        distributor_id: 'yum_distributor',
                        distributor_type_id: 'yum_distributor',
                        distributor_config: yum_dist_config
                      },
                      {
                        distributor_id: 'export_distributor',
                        distributor_type_id: 'export_distributor',
                        distributor_config: export_dist_config
                      }
                    ]
                  }.merge(repo_config)
    end

    def update_repo
      api_request "repositories/#{new_resource.repo_id}/", 'put', \
                  delta: repo_config,
                  importer_config: importer_config,
                  distributor_configs: {
                    yum_distributor_config: yum_dist_config,
                    export_distributor_config: export_dist_config
                  }
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
                  'post', id: 'yum_distributor'
    end
  end
end

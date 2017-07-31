#
# Cookbook:: pulp_server
# Resource:: pulp_rpm_repo
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

require 'httpclient'

resource_name :pulp_rpm_repo

property :repo_id, String, name_property: true
property :host, String, \
         required: true, default: 'localhost', desired_state: false
property :username, String, \
         required: true, default: 'admin', desired_state: false
property :password, String, \
         required: true, default: 'admin', desired_state: false
property :host_ca_cert, String, desired_state: false
property :host_ca_verify, [true, false], default: true, desired_state: false
property :display_name, [String, nil], default: nil
property :description, [String, nil], default: nil
property :feed, [String, nil], default: nil
# property :validate, [true, false], default: true
property :skip, [Array, nil], default: nil
property :require_signature, [true, false, nil], default: nil
property :allowed_keys, [Array, nil], default: nil
property :ssl_ca_cert, [String, nil], default: nil
property :ssl_validation, [true, false, nil], default: nil
property :ssl_client_cert, [String, nil], default: nil
property :ssl_client_key, [String, nil], default: nil
property :relative_url, [String, nil], default: lazy { repo_id }
property :max_downloads, [Integer, nil], default: nil
property :max_speed, [Integer, nil], default: nil
property :remove_missing, [true, false, nil], default: nil
property :retain_old_count, [Integer, nil], default: nil
property :download_policy, [String, nil], \
         equal_to: %w[immediate background on_demand], default: nil
property :http, [true, false, nil], default: true
property :https, [true, false, nil], default: false
property :checksum_type, [String, nil], default: nil
property :gpg_key, [String, nil], default: nil
property :generate_sqlite, [true, false, nil], default: nil
property :repoview, [true, false, nil], default: nil
property :updateinfo_checksum_type, [true, false, nil], default: nil

default_action :create

# rubocop:disable MethodLength
def repo_details(res)
  client = HTTPClient.new(force_basic_auth: true)
  client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE \
    unless res.host_ca_verify
  client.ssl_config.set_trust_ca(res.host_ca_cert) \
    if res.host_ca_cert
  client.set_auth nil, res.username, res.password

  begin
    JSON.parse(
      client.get_content(
        "https://#{res.host}/pulp/api/v2/repositories/#{res.repo_id}/",
        details: true
      )
    )
  rescue JSON::ParserError
    Chef::Log.fatal('Error parsing response from pulp server')
    raise
  rescue HTTPClient::BadResponseError
    nil
  end
end

load_current_value do |desired_resource|
  repo = repo_details desired_resource
  if repo
    # basic repository config
    config = {
      display_name: repo['display_name'],
      description: repo['description']
    }

    # yum importer config
    config.merge!(repo['importers'].first['config'])

    # yum_distributor config
    config.merge!(repo['distributors'] \
      .select { |i| i['id'] == 'yum_distributor' }.first['config'])

    config.each do |k, v|
      send k, v if self.class.properties.key?(k.to_sym)
    end
  else
    current_value_does_not_exist!
  end
end

action :create do
  converge_if_changed do
    if current_resource.nil?
      converge_by("Creating a pulp rpm repository #{new_resource}") do
        create_repo
      end
    else
      converge_by("Updating a pulp rpm repository #{new_resource}") do
        update_repo
      end
    end
  end
end

action :delete do
  converge_by("Deleting a pulp rpm repository #{new_resource}") do
    delete_repo
  end
end

action :publish do
  converge_by("Creating a publish task for #{new_resource}") do
    publish_repo
  end
end

action :sync do
  converge_by("Creating a sync task for #{new_resource}") do
    sync_repo
  end
end

action_class do
  include PulpServerCookbook::Helpers
end

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
property :host, String, required: true, default: 'localhost', desired_state: false
property :username, String, required: true, default: 'admin', desired_state: false
property :password, String, required: true, default: 'admin', desired_state: false
property :display_name, [String, nil], default: nil
property :description, [String, nil], default: nil
property :feed, [String, nil], default: nil
# property :validate, [true, false], default: true
property :skip, [Array, nil], default: nil
property :require_signature, [true, false, nil], default: nil
property :allowed_keys, [Array, nil], default: nil
property :feed_ca_cert, [String, nil], default: nil
property :verify_feed_ssl, [true, false, nil], default: nil
property :feed_cert, [String, nil], default: nil
property :feed_key, [String, nil], default: nil
property :relative_url, [String, nil], default: nil
property :max_downloads, [Integer, nil], default: nil
property :max_speed, [Integer, nil], default: nil
property :remove_missing, [true, false, nil], default: nil
property :retain_old_count, [Integer, nil], default: nil
property :download_policy, [String, nil], \
  equal_to: ['immediate', 'background', 'on_demand'], default: nil
property :serve_http, [true, false, nil], default: nil
property :serve_https, [true, false, nil], default: nil
property :checksum_type, [String, nil], default: nil
property :gpg_key, [String, nil], default: nil
property :generate_sqlite, [true, false, nil], default: nil
property :repoview, [true, false, nil], default: nil
property :updateinfo_checksum_type, [true, false, nil], default: nil

default_action :create

def set_value(prop, value)
  send prop, value if value
end

load_current_value do |desired_resource|

  client = HTTPClient.new(:force_basic_auth => true)
  client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  client.set_auth nil, desired_resource.username, desired_resource.password
  repo = JSON.parse(client.get_content(
             "https://#{desired_resource.host}" \
             "/pulp/api/v2/repositories/" \
             "#{desired_resource.repo_id}/"))

  if repo
    set_value :display_name, repo['display_name']
    set_value :description, repo['description']
    set_value :feed, repo['feed']
    set_value :require_signature, repo['require_signature']
    set_value :allowed_keys, repo['allowed_keys']
    set_value :feed_ca_cert, repo['feed_ca_cert']
    set_value :verify_feed_ssl, repo['verify_feed_ssl']
    set_value :feed_cert, repo['feed_cert']
    set_value :feed_key, repo['feed_key']
    set_value :max_downloads, repo['max_downloads']
    set_value :max_speed, repo['max_speed']
    set_value :remove_missing, repo['remove_missing']
    set_value :retain_old_count, repo['retain_old_count']
    set_value :download_policy, repo['download_policy']
    set_value :serve_http, repo['serve_http']
    set_value :serve_https, repo['serve_https']
    set_value :checksum_type, repo['checksum_type']
    set_value :gpg_key, repo['generate_sqlite']
    set_value :repoview, repo['repoview']
    set_value :updateinfo_checksum_type, repo['updateinfo_checksum_type']
  else
    current_value_does_not_exist!
  end
end

action :create do
  converge_if_changed do
    update_repo
  end
end

action :delete do
end

action :publish do
end

action :sync do
end

action_class do
  include PulpServerCookbook::Helpers
end

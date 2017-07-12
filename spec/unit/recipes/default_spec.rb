#
# Cookbook:: pulp_server
# Spec:: default
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

require 'spec_helper'

describe 'pulp_server::default' do
  context 'When all attributes are default, on an CentOS 7.3' do
    before do
      stub_command('sudo -u apache /usr/bin/pulp-manage-db --dry-run')
        .and_return(false)
    end

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos',
                                          version: '7.3.1611')
      runner.converge(described_recipe)
    end

    it 'includes the `repos` recipe' do
      expect(chef_run).to include_recipe('pulp_server::repos')
    end

    it 'includes the `mongodb` recipe' do
      expect(chef_run).to include_recipe('pulp_server::mongodb')
    end

    it 'includes the `qpid` recipe' do
      expect(chef_run).to include_recipe('pulp_server::qpid')
    end

    it 'includes the `admin` recipe' do
      expect(chef_run).to include_recipe('pulp_server::admin')
    end
  end
end

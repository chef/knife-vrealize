#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'
require 'chef/knife/vra_server_create'
require 'support/shared_examples_for_command'
require 'support/shared_examples_for_servercreatecommand'

describe Chef::Knife::Cloud::VraServerCreate do
  before(:each) do
    Chef::Config.reset
  end

  argv = []
  argv += %w(--cpus 1)
  argv += %w(--memory 512)
  argv += %w(--requested-for myuser@corp.local)
  argv += %w(--bootstrap-protocol ssh)
  argv += %w(--ssh-password password)
  argv += %w(--extra-param key1=string:value1)
  argv += %w(--extra-param key2=integer:2)
  argv += %w(d5ba201a-449f-47a4-9d02-39196224bf01)

  subject { Chef::Knife::Cloud::VraServerCreate.new(argv) }

  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraServerCreate.new(argv)
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::VraServerCreate.new(argv)

  describe '#validate_params!' do
    context 'when no catalog ID is supplied' do
      it 'raises an error' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)

        command = Chef::Knife::Cloud::VraServerCreate.new(argv)
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    it 'validates extra parameters' do
      expect(subject).to receive(:validate_extra_params!)
      subject.validate_params!
    end
  end

  describe '#extra_params' do
    context 'when there are no extra params' do
      before do
        Chef::Config[:knife][:vra_extra_params] = {}
      end

      it 'returns nil' do
        expect(subject.extra_params).to eq(nil)
      end
    end

    context 'when extra params are provided' do
      before do
        Chef::Config[:knife][:vra_extra_params] = {
          'key1' => 'string:value1',
          'key2' => 'integer:2'
        }
      end

      it 'parses extra parameters properly' do
        params = subject.extra_params
        expect(params[0][:key]).to eq 'key1'
        expect(params[0][:type]).to eq 'string'
        expect(params[0][:value]).to eq 'value1'
        expect(params[1][:key]).to eq 'key2'
        expect(params[1][:type]).to eq 'integer'
        expect(params[1][:value]).to eq '2'
      end
    end
  end

  describe '#validate_extra_params!' do
    context 'when no extra parameters are supplied' do
      it 'does not raise an exception' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)
        command = Chef::Knife::Cloud::VraServerCreate.new(argv)

        expect { command.validate_extra_params! }.not_to raise_error
      end
    end

    context 'when correct parameters are supplied' do
      it 'does not raise an exception' do
        expect { subject.validate_extra_params! }.not_to raise_error
      end
    end

    context 'when a type or value is missing' do
      it 'raises an exception' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)
        argv += %w(d5ba201a-449f-47a4-9d02-39196224bf01)
        argv += %w(--extra-param key1=value1)
        command = Chef::Knife::Cloud::VraServerCreate.new(argv)

        expect { command.validate_extra_params! }.to raise_error(ArgumentError)
      end
    end

    context 'when an invalid parameter type is provided' do
      it 'raises an exception' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)
        argv += %w(d5ba201a-449f-47a4-9d02-39196224bf01)
        argv += %w(--extra-param key1=faketype:value1)
        command = Chef::Knife::Cloud::VraServerCreate.new(argv)

        expect { command.validate_extra_params! }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#hostname_for_server' do
    let(:server)       { double('server') }
    let(:ip_addresses) { [ '1.2.3.4' ] }

    it 'returns the IP address if it exists' do
      allow(subject).to receive(:server).and_return(server)
      allow(server).to receive(:ip_addresses).and_return(ip_addresses)

      expect(subject.hostname_for_server).to eq('1.2.3.4')
    end

    it 'returns the hostname if the IP address is missing' do
      allow(subject).to receive(:server).and_return(server)
      allow(server).to receive(:ip_addresses).and_return([])
      allow(server).to receive(:name).and_return('test_name')

      expect(subject.hostname_for_server).to eq('test_name')
    end
  end
end

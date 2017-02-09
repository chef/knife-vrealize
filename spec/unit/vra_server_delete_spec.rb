# frozen_string_literal: true
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
require 'chef/knife/vra_server_delete'
require 'support/shared_examples_for_command'
require 'support/shared_examples_for_serverdeletecommand'

describe Chef::Knife::Cloud::VraServerDelete do
  subject { Chef::Knife::Cloud::VraServerDelete.new(%w(12345 54321)) }

  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraServerDelete.new(%w(12345 54321))

  describe '#validate_params!' do
    context 'when no resource IDs are supplied' do
      let(:command) { Chef::Knife::Cloud::VraServerDelete.new }
      it 'prints an error and exits' do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end
  end

  describe '#execute_command' do
    before(:each) do
      server1 = double('server1', name: 'server1')
      server2 = double('server2', name: 'server2')
      allow(subject).to receive_message_chain(:service, :get_server).with('12345').and_return(server1)
      allow(subject).to receive_message_chain(:service, :get_server).with('54321').and_return(server2)
    end

    it 'calls delete_server for each server' do
      allow(subject).to receive(:delete_from_chef).with('server1')
      allow(subject).to receive(:delete_from_chef).with('server2')
      expect(subject).to receive_message_chain(:service, :delete_server).with('12345')
      expect(subject).to receive_message_chain(:service, :delete_server).with('54321')
      subject.execute_command
    end

    it 'calls delete_from_chef using the server names for each server' do
      allow(subject).to receive_message_chain(:service, :delete_server).with('12345')
      allow(subject).to receive_message_chain(:service, :delete_server).with('54321')
      expect(subject).to receive(:delete_from_chef).with('server1')
      expect(subject).to receive(:delete_from_chef).with('server2')
      subject.execute_command
    end
  end
end

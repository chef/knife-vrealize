require 'spec_helper'
require 'chef/knife/vra_server_delete'
require 'support/shared_examples_for_command'
require 'support/shared_examples_for_serverdeletecommand'

describe Chef::Knife::Cloud::VraServerDelete do
  subject { Chef::Knife::Cloud::VraServerDelete.new([12345, 54321]) }

  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraServerDelete.new([12345, 54321])
  #it_behaves_like Chef::Knife::Cloud::ServerDeleteCommand, Chef::Knife::Cloud::VraServerDelete.new([12345])

  describe '#execute_command' do
    before(:each) do
      server1 = double('server1', name: 'server1')
      server2 = double('server2', name: 'server2')
      allow(subject).to receive_message_chain(:service, :get_server).with(12345).and_return(server1)
      allow(subject).to receive_message_chain(:service, :get_server).with(54321).and_return(server2)
    end

    it 'calls delete_server for each server' do
      allow(subject).to receive(:delete_from_chef).with('server1')
      allow(subject).to receive(:delete_from_chef).with('server2')
      expect(subject).to receive_message_chain(:service, :delete_server).with(12345)
      expect(subject).to receive_message_chain(:service, :delete_server).with(54321)
      subject.execute_command
    end

    it 'calls delete_from_chef using the server names for each server' do
      allow(subject).to receive_message_chain(:service, :delete_server).with(12345)
      allow(subject).to receive_message_chain(:service, :delete_server).with(54321)
      expect(subject).to receive(:delete_from_chef).with('server1')
      expect(subject).to receive(:delete_from_chef).with('server2')
      subject.execute_command
    end
  end
end

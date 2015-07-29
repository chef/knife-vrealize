require 'spec_helper'
require 'chef/knife/vra_server_list'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::VraServerList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraServerList.new

  subject { described_class.new }

  describe '#format_status_value' do
    context 'when the status is "active"' do
      it 'displays with green' do
        expect(subject.ui).to receive(:color).with('active', :green)
        subject.format_status_value('active')
      end
    end

    context 'when the status is "deleted"' do
      it 'displays with red' do
        expect(subject.ui).to receive(:color).with('deleted', :red)
        subject.format_status_value('deleted')
      end
    end

    context 'when the status is anything else' do
      it 'displays with yellow' do
        expect(subject.ui).to receive(:color).with('unknown', :yellow)
        subject.format_status_value('unknown')
      end
    end
  end
end

require 'spec_helper'
require 'chef/knife/vra_catalog_list'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::VraCatalogList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraCatalogList.new

  subject { described_class.new }

  describe '#format_status_value' do
    context 'when the status is "published"' do
      it 'displays with green' do
        expect(subject.ui).to receive(:color).with('published', :green)
        subject.format_status_value('published')
      end
    end

    context 'when the status it not "published"' do
      it 'displays with red' do
        expect(subject.ui).to receive(:color).with('unpublished', :red)
        subject.format_status_value('unpublished')
      end
    end
  end
end
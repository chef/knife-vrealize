# frozen_string_literal: true
#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: 2015-2019, Chef Software, Inc.
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

require "spec_helper"
require "chef/knife/vra_catalog_list"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::VraCatalogList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraCatalogList.new

  subject { described_class.new }

  describe "#format_status_value" do
    context 'when the status is "published"' do
      it "displays with green" do
        expect(subject.ui).to receive(:color).with("published", :green)
        subject.format_status_value("published")
      end
    end

    context 'when the status it not "published"' do
      it "displays with red" do
        expect(subject.ui).to receive(:color).with("unpublished", :red)
        subject.format_status_value("unpublished")
      end
    end
  end
end

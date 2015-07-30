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

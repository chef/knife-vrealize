# frozen_string_literal: true
#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: Copyright (c) Chef Software Inc.
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
require "chef/knife/vra_server_show"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::VraServerShow do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraServerShow.new

  describe "#validate_params!" do
    context "when no resources are supplied" do
      let(:command) { Chef::Knife::Cloud::VraServerShow.new }
      it "prints an error and exits" do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    context "when more than one resource is supplied" do
      let(:command) { Chef::Knife::Cloud::VraServerShow.new(%w{12345 54321}) }
      it "prints an error and exits" do
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end
  end
end

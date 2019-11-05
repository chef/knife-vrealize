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
require "chef/knife"
require "chef/knife/cloud/vra_service"
require "chef/knife/cloud/vra_service_helpers"

class HelpersTester
  include Chef::Knife::Cloud::VraServiceHelpers
  attr_accessor :ui
end

describe "Chef::Knife::Cloud::VraServiceHelpers" do
  subject { HelpersTester.new }

  before(:each) do
    subject.ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
  end

  describe "#create_service_instance" do
    it "creates a service instance" do
      allow(subject).to receive(:locate_config_value).with(:vra_username).and_return("myuser")
      allow(subject).to receive(:locate_config_value).with(:vra_password).and_return("mypassword")
      allow(subject).to receive(:locate_config_value).with(:vra_base_url).and_return("https://vra.corp.local")
      allow(subject).to receive(:locate_config_value).with(:vra_tenant).and_return("mytenant")
      allow(subject).to receive(:locate_config_value).with(:vra_page_size).and_return(50)
      allow(subject).to receive(:locate_config_value).with(:vra_disable_ssl_verify).and_return(false)

      expect(Chef::Knife::Cloud::VraService).to receive(:new)
        .with(username:   "myuser",
              password:   "mypassword",
              base_url:   "https://vra.corp.local",
              tenant:     "mytenant",
              page_size:  50,
              verify_ssl: true)

      subject.create_service_instance
    end
  end

  describe "#verify_ssl?" do
    context "when vra_disable_ssl_verify is true" do
      it "returns false" do
        allow(subject).to receive(:locate_config_value).with(:vra_disable_ssl_verify).and_return(true)
        expect(subject.verify_ssl?).to be false
      end
    end

    context "when vra_disable_ssl_verify is false" do
      it "returns true" do
        allow(subject).to receive(:locate_config_value).with(:vra_disable_ssl_verify).and_return(false)
        expect(subject.verify_ssl?).to be true
      end
    end
  end

  describe "#wait_for_request" do
    before(:each) do
      # muffle any stdout output from this method
      allow(subject).to receive(:print)

      # don't actually sleep
      allow(subject).to receive(:sleep)
    end

    context "when the requests completes normally, 3 loops" do
      it "only refreshes the request 3 times" do
        request = double("request")
        allow(request).to receive(:status)
        allow(request).to receive(:completed?).exactly(3).times.and_return(false, false, true)
        expect(request).to receive(:refresh).exactly(3).times

        subject.wait_for_request(request)
      end
    end

    context "when the request is completed on the first loop" do
      it "only refreshes the request 1 time" do
        request = double("request")
        allow(request).to receive(:status)
        allow(request).to receive(:completed?).once.and_return(true)
        expect(request).to receive(:refresh).once

        subject.wait_for_request(request)
      end
    end

    context "when the timeout is exceeded" do
      it "prints a warning and exits" do
        request = double("request")
        allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        expect(subject.ui).to receive(:msg).with("")
        expect(subject.ui).to receive(:error)
          .with("Request did not complete in 600 seconds. Check the Requests tab in the vRA UI for more information.")
        expect { subject.wait_for_request(request) }.to raise_error(SystemExit)
      end
    end

    context "when a non-timeout exception is raised" do
      it "raises the original exception" do
        request = double("request")
        allow(request).to receive(:refresh).and_raise(RuntimeError)
        expect { subject.wait_for_request(request) }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#validate!" do
    it "calls checks for empty VRA connection configuration values" do
      expect(subject).to receive(:check_for_missing_config_values!)
        .with(:vra_username, :vra_password, :vra_base_url, :vra_tenant)

      subject.validate!
    end
  end

  describe "#check_for_missing_config_values!" do
    context "when all values exist" do
      it "does not raise an error" do
        allow(subject).to receive(:locate_config_value).with(:key1).and_return("value")
        allow(subject).to receive(:locate_config_value).with(:key2).and_return("value")
        expect(subject.ui).not_to receive(:error)
        expect { subject.check_for_missing_config_values!(:key1, :key2) }.not_to raise_error
      end
    end

    context "when a value does not exist" do
      it "prints an error and exits" do
        allow(subject).to receive(:locate_config_value).with(:key1).and_return("value")
        allow(subject).to receive(:locate_config_value).with(:key2).and_return(nil)
        expect(subject.ui).to receive(:error)
        expect { subject.check_for_missing_config_values!(:key1, :key2) }.to raise_error(SystemExit)
      end
    end
  end
end

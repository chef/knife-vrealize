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
require "chef/knife/vro_workflow_execute"

describe Chef::Knife::VroWorkflowExecute do
  let(:workflow_name)          { "test workflow" }
  let(:workflow_id)            { "1d335f85-5328-42fc-a842-a956d1ccdf08" }
  let(:vro_username)           { "myuser" }
  let(:vro_password)           { "mypassword" }
  let(:vro_base_url)           { "https://vro.corp.local" }
  let(:vro_disable_ssl_verify) { true }
  let(:key1)                   { "value1" }
  let(:key2)                   { "2" }

  let(:argv) do
    [ workflow_name,
      "key1=#{key1}",
      "key2=#{key2}",
      "--vro-workflow-id", workflow_id]
  end

  subject { described_class.new(argv) }

  before(:each) do
    Chef::Config[:knife][:vro_username]           = vro_username
    Chef::Config[:knife][:vro_password]           = vro_password
    Chef::Config[:knife][:vro_base_url]           = vro_base_url
    Chef::Config[:knife][:vro_disable_ssl_verify] = vro_disable_ssl_verify
  end

  describe "#verify_ssl?" do
    context "when vro_disable_ssl_verify is set to true" do
      let(:vro_disable_ssl_verify) { true }
      it "returns false" do
        expect(subject.verify_ssl?).to eq(false)
      end
    end

    context "when vro_disable_ssl_verify is set to false" do
      let(:vro_disable_ssl_verify) { false }
      it "returns true" do
        expect(subject.verify_ssl?).to eq(true)
      end
    end
  end

  describe "#vro_config" do
    it "creates a config object" do
      expect(VcoWorkflows::Config).to receive(:new).with(url: vro_base_url,
                                                         username: vro_username,
                                                         password: vro_password,
                                                         verify_ssl: false)
      subject.vro_config
    end
  end

  describe "#vro_client" do
    it "creates a client object" do
      config = double("config")
      allow(subject).to receive(:vro_config).and_return(config)
      expect(VcoWorkflows::Workflow).to receive(:new).with(workflow_name,
        id: workflow_id,
        config: config)

      subject.set_parameters
      subject.vro_client
    end
  end

  describe "#parse_and_validate_params" do
    context "when proper parameters are supplied" do
      let(:args) { %w{key1=value1 key2=value2} }
      it "returns a hash of parameters" do
        expect(subject.parse_and_validate_params!(args)).to eq("key1" => "value1",
                                                               "key2" => "value2")
      end
    end

    context "when a parameter is malformed" do
      let(:args) { %w{key1=value1 key2} }
      it "raises an exception" do
        expect { subject.parse_and_validate_params!(args) }.to raise_error(RuntimeError)
      end
    end
  end

  describe "execute_workflow" do
    before do
      config = double("config")
      client = double("client")
      allow(subject).to receive(:vro_config).and_return(config)
      allow(subject).to receive(:vro_client).and_return(client)
      allow(client).to receive(:parameter)
      allow(client).to receive(:execute)
      subject.set_parameters
    end

    it "sets the workflow parameters" do
      expect(subject.vro_client).to receive(:parameter).with("key1", key1)
      expect(subject.vro_client).to receive(:parameter).with("key2", key2)

      subject.execute_workflow
    end

    it "executes the workflow" do
      expect(subject.vro_client).to receive(:execute)
      subject.execute_workflow
    end

    context "when execute fails with a RestClient::BadRequest" do
      it "prints an error with the HTTP response" do
        HTTPResponse = Struct.new(:code, :to_s)
        response = HTTPResponse.new(400, "an HTTP error occurred")
        exception = RestClient::BadRequest.new
        exception.response = response
        allow(subject.vro_client).to receive(:execute).and_raise(exception)
        expect(subject.ui).to receive(:error).with("The workflow execution request failed: an HTTP error occurred")
        expect { subject.execute_workflow }.to raise_error(RestClient::BadRequest)
      end
    end

    context "when execute fails with any other exception" do
      it "prints an error with the exception message" do
        allow(subject.vro_client).to receive(:execute).and_raise(RuntimeError, "a non-HTTP error occurred")
        expect(subject.ui).to receive(:error).with("The workflow execution request failed: a non-HTTP error occurred")
        expect { subject.execute_workflow }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#wait_for_workflow" do
    before(:each) do
      # don't actually sleep
      allow(subject).to receive(:sleep)
    end

    context "when the requests completes normally, 3 loops" do
      it "only fetches the token 3 times" do
        client = double("client")
        token  = double("token")
        allow(subject).to receive(:vro_client).and_return(client)
        allow(client).to receive(:token).and_return(token)
        allow(token).to receive(:alive?).exactly(3).times.and_return(true, true, false)

        expect(subject.vro_client).to receive(:token).exactly(3).times
        subject.wait_for_workflow
      end
    end

    context "when the request is completed on the first loop" do
      it "only refreshes the request 1 time" do
        client = double("client")
        token  = double("token")
        allow(subject).to receive(:vro_client).and_return(client)
        allow(client).to receive(:token).and_return(token)
        expect(token).to receive(:alive?).once.and_return(false)

        subject.wait_for_workflow
      end
    end

    context "when the timeout is exceeded" do
      before do
        Chef::Config[:knife][:request_timeout] = 600
      end
      it "raises a Timeout exception" do
        allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        expect { subject.wait_for_workflow }.to raise_error(
          Timeout::Error, "Workflow did not complete in 600 seconds. " \
                          "Please check the vRO UI for more information." \
        )
      end
    end

    context "when a non-timeout exception is raised" do
      it "raises the original exception" do
        client = double("client")
        allow(subject).to receive(:vro_client).and_return(client)
        allow(client).to receive(:token).and_raise(RuntimeError, "an error occurred")
        expect { subject.wait_for_workflow }.to raise_error(RuntimeError, "an error occurred")
      end
    end
  end

  describe "#missing_config_parameters" do
    context "when all parameters are supplied" do
      it "returns an empty array" do
        expect(subject.missing_config_parameters).to eq([])
      end
    end

    context "when a parameter is missing" do
      before do
        Chef::Config[:knife][:vro_username] = nil
      end
      it "returns an array with that parameter" do
        expect(subject.missing_config_parameters).to eq([ :vro_username ])
      end
    end
  end

  describe "#validate!" do
    context "when a config parameter is missing" do
      it "calls #print_error_and_exit" do
        allow(subject).to receive(:missing_config_parameters).and_return([ :parameter ])
        expect(subject).to receive(:print_error_and_exit)

        subject.validate!
      end
    end

    context "when no workflow name is provided" do
      let(:knife) { Chef::Knife::VroWorkflowExecute.new }
      it "calls #print_error_and_exit" do
        expect(knife).to receive(:print_error_and_exit)

        knife.validate!
      end
    end
  end

  describe "#print_error_and_exit" do
    it "prints an error and exits" do
      expect(subject.ui).to receive(:error).with("an error occurred")
      expect { subject.print_error_and_exit("an error occurred") }.to raise_error(SystemExit)
    end
  end

  describe "#print_results" do
    it "prints a blank line and calls the other print methods" do
      expect(subject.ui).to receive(:msg).with("")
      expect(subject).to receive(:print_output_parameters)
      expect(subject).to receive(:print_execution_log)

      subject.print_results
    end
  end

  describe "#print_output_parameters" do
    context "when there are no output parameters" do
      before do
        client = double("client")
        token  = double("token")
        allow(subject).to receive(:vro_client).and_return(client)
        allow(client).to receive(:token).and_return(token)
        allow(token).to receive(:output_parameters).and_return({})
      end

      it "does not print any output" do
        expect(subject.ui).not_to receive(:msg)

        subject.print_output_parameters
      end
    end

    context "when output parameters exist" do
      before do
        client = double("client")
        token  = double("token")
        param1 = double("param1", value: "value1", type: "string")
        param2 = double("param2", value: 2.0, type: "number")
        allow(subject).to receive(:vro_client).and_return(client)
        allow(client).to receive(:token).and_return(token)
        allow(token).to receive(:output_parameters).and_return(
          "key1" => param1,
          "key2" => param2
        )

        # squelch output during testing
        allow(subject.ui).to receive(:msg)
        allow(subject).to receive(:msg_pair)
      end

      it "prints a header and a blank line" do
        header = subject.ui.color("Output Parameters:", :bold)
        expect(subject.ui).to receive(:msg).with(header)
        expect(subject.ui).to receive(:msg).with("")

        subject.print_output_parameters
      end

      it "prints out the output parameters" do
        expect(subject).to receive(:msg_pair).with("key1", "value1 (string)")
        expect(subject).to receive(:msg_pair).with("key2", "2.0 (number)")

        subject.print_output_parameters
      end
    end
  end

  describe "#print_execution_log" do
    context "when the log is empty" do
      before do
        client = double("client", log: nil)
        allow(subject).to receive(:vro_client).and_return(client)
      end

      it "does not print any information" do
        expect(subject.ui).not_to receive(:msg)

        subject.print_execution_log
      end
    end

    context "when the log exists" do
      before do
        client = double("client", log: "log entries go here")
        allow(subject).to receive(:vro_client).and_return(client)
      end

      it "prints a header and the log entry" do
        header = subject.ui.color("Workflow Execution Log:", :bold)
        expect(subject.ui).to receive(:msg).with(header)
        expect(subject.ui).to receive(:msg).with("log entries go here")

        subject.print_execution_log
      end
    end
  end

  describe "#set_parameters" do
    it "sets the instance variables correctly" do
      subject.set_parameters

      expect(subject.workflow_name).to eq(workflow_name)
      expect(subject.workflow_id).to eq(workflow_id)
      expect(subject.parameters).to eq(
        "key1" => "value1",
        "key2" => "2"
      )
    end
  end

  describe "#run" do
    it "calls the correct methods" do
      expect(subject).to receive(:validate!)
      expect(subject).to receive(:set_parameters)
      expect(subject.ui).to receive(:msg).with("Starting workflow execution...")
      expect(subject).to receive(:execute_workflow).and_return("12345")
      expect(subject.ui).to receive(:msg).with("Workflow execution 12345 started. Waiting for it to complete...")
      expect(subject).to receive(:wait_for_workflow)
      expect(subject.ui).to receive(:msg).with("Workflow execution complete.")
      expect(subject).to receive(:print_results)

      subject.run
    end
  end
end

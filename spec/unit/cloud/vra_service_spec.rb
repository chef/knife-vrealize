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
require 'chef/knife/cloud/exceptions'
require 'chef/knife/cloud/vra_service'
require 'support/shared_examples_for_service'

describe Chef::Knife::Cloud::VraService do
  subject do
    Chef::Knife::Cloud::VraService.new(username:   'myuser',
                                       password:   'mypassword',
                                       base_url:   'https://vra.corp.local',
                                       tenant:     'mytenant',
                                       verify_ssl: true)
  end

  before(:each) do
    subject.ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
    allow(subject.ui).to receive(:msg).with('')
  end

  describe '#connection' do
    it 'creates a Vra::Client object' do
      expect(subject.connection).to be_an_instance_of(Vra::Client)
    end
  end

  describe '#create_server' do
    before(:each) do
      allow(subject.ui).to receive(:msg).with('Catalog request 1 submitted.')
      allow(subject.ui).to receive(:msg).with("Catalog request complete.\n")
    end

    context 'when the request is successful' do
      it 'calls all the appropriate methods' do
        submitted_request = double('submitted_request', id: 1, failed?: false)
        resource = double('resource', vm?: true)
        allow(submitted_request).to receive(:resources).and_return([resource])
        expect(subject).to receive_message_chain(:catalog_request, :submit).and_return(submitted_request)
        expect(subject).to receive(:wait_for_request)
        expect(subject).to receive(:request_summary)

        server = subject.create_server
        expect(server).to eq resource
      end
    end

    context 'when the request failed' do
      it 'raises an exception' do
        submitted_request = double('submitted_request', id: 1, failed?: true, completion_details: 'it failed')
        expect(subject).to receive_message_chain(:catalog_request, :submit).and_return(submitted_request)
        expect(subject).to receive(:wait_for_request)
        expect(subject).to receive(:request_summary)

        expect { subject.create_server }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
      end
    end

    context 'when the request returns no resources' do
      it 'raises an exception' do
        submitted_request = double('submitted_request', id: 1, failed?: false)
        allow(submitted_request).to receive(:resources).and_return([])
        expect(subject).to receive_message_chain(:catalog_request, :submit).and_return(submitted_request)
        expect(subject).to receive(:wait_for_request)
        expect(subject).to receive(:request_summary)

        expect { subject.create_server }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
      end
    end

    context 'when the request returns more than one VM resource' do
      it 'raises an exception' do
        submitted_request = double('submitted_request', id: 1, failed?: false)
        resource1 = double('resource1', vm?: true)
        resource2 = double('resource2', vm?: true)
        allow(submitted_request).to receive(:resources).and_return([resource1, resource2])
        expect(subject).to receive_message_chain(:catalog_request, :submit).and_return(submitted_request)
        expect(subject).to receive(:wait_for_request)
        expect(subject).to receive(:request_summary)

        expect { subject.create_server }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
      end
    end

    context 'when the request returns multiple resources, but only 1 VM' do
      it 'happily returns the server resource' do
        submitted_request = double('submitted_request', id: 1, failed?: false)
        resource1 = double('resource1', vm?: true)
        resource2 = double('resource2', vm?: false)
        allow(submitted_request).to receive(:resources).and_return([resource1, resource2])
        expect(subject).to receive_message_chain(:catalog_request, :submit).and_return(submitted_request)
        expect(subject).to receive(:wait_for_request)
        expect(subject).to receive(:request_summary)

        server = subject.create_server
        expect(server).to eq resource1
      end
    end
  end

  describe '#delete_server' do
    context 'when the server exists' do
      it 'calls the appropriate methods' do
        server = double('server', status: 'ACTIVE')
        destroy_request = double('destroy_request', id: 1)
        expect(subject).to receive(:get_server).with('12345').and_return(server)
        expect(subject).to receive(:server_summary).with(server)
        expect(subject.ui).to receive(:confirm)
        expect(server).to receive(:destroy).and_return(destroy_request)
        expect(subject.ui).to receive(:msg).with('Destroy request 1 submitted.')
        expect(subject).to receive(:wait_for_request)
        expect(subject.ui).to receive(:msg).with('Destroy request complete.')
        expect(subject).to receive(:request_summary)

        subject.delete_server('12345')
      end
    end

    context 'when the server is already deleted' do
      it 'does not call #destroy on the server object' do
        server = double('server', status: 'DELETED')
        expect(subject).to receive(:get_server).with('12345').and_return(server)
        expect(subject).to receive(:server_summary).with(server)
        expect(subject.ui).to receive(:warn).with('Server is already deleted.')
        expect(server).not_to receive(:destroy)

        subject.delete_server('12345')
      end
    end
  end

  describe '#list_servers' do
    it 'calls all_resources' do
      expect(subject).to receive_message_chain(:connection, :resources, :all_resources)
        .and_return([])

      subject.list_servers
    end
  end

  describe '#list_catalog_items' do
    context 'when requesting entitled items only' do
      it 'calls entitled_items' do
        expect(subject).to receive_message_chain(:connection, :catalog, :entitled_items)

        subject.list_catalog_items(true)
      end
    end

    context 'when requesting all items' do
      it 'calls all_items' do
        expect(subject).to receive_message_chain(:connection, :catalog, :all_items)

        subject.list_catalog_items(false)
      end
    end
  end

  describe '#get_server' do
    it 'calls resources.by_id' do
      expect(subject).to receive_message_chain(:connection, :resources, :by_id).with('12345')

      subject.get_server('12345')
    end
  end

  describe '#catalog_request' do
    context 'when handling a proper request' do
      it 'calls the appropriate methods' do
        catalog_request = double('catalog_request')
        expect(catalog_request).to receive(:cpus=).with(1)
        expect(catalog_request).to receive(:memory=).with(512)
        expect(catalog_request).to receive(:requested_for=).with('myuser@corp.local')
        expect(catalog_request).to receive(:lease_days=).with(5)
        expect(catalog_request).to receive(:notes=).with('my notes')
        expect(catalog_request).to receive(:subtenant_id=).with('tenant1')
        expect(subject).to receive_message_chain(:connection, :catalog, :request)
          .with('12345')
          .and_return(catalog_request)

        subject.catalog_request(catalog_id: '12345',
                                cpus: 1,
                                memory: 512,
                                requested_for: 'myuser@corp.local',
                                lease_days: 5,
                                notes: 'my notes',
                                subtenant_id: 'tenant1')
      end
    end

    context 'when optional arguments are missing' do
      it 'does not call the attr setters for the missing attributes' do
        catalog_request = double('catalog_request')
        expect(catalog_request).to receive(:cpus=).with(1)
        expect(catalog_request).to receive(:memory=).with(512)
        expect(catalog_request).to receive(:requested_for=).with('myuser@corp.local')
        expect(catalog_request).to_not receive(:lease_days=)
        expect(catalog_request).to_not receive(:notes=)
        expect(catalog_request).to_not receive(:subtenant_id=)
        expect(subject).to receive_message_chain(:connection, :catalog, :request)
          .with('12345')
          .and_return(catalog_request)

        subject.catalog_request(catalog_id: '12345',
                                cpus: 1,
                                memory: 512,
                                requested_for: 'myuser@corp.local')
      end
    end

    context 'when extra parameters are supplied' do
      it 'calls set_parameter on the catalog_request' do
        catalog_request = double('catalog_request')
        expect(catalog_request).to receive(:cpus=).with(1)
        expect(catalog_request).to receive(:memory=).with(512)
        expect(catalog_request).to receive(:requested_for=).with('myuser@corp.local')
        expect(catalog_request).to receive(:set_parameter).with('key1', 'string', 'value1')
        expect(catalog_request).to receive(:set_parameter).with('key2', 'integer', '2')
        expect(subject).to receive_message_chain(:connection, :catalog, :request)
          .with('12345')
          .and_return(catalog_request)

        subject.catalog_request(catalog_id: '12345',
                                cpus: 1,
                                memory: 512,
                                requested_for: 'myuser@corp.local',
                                vra_extra_params: {
                                  'key1' => { type: 'string', value: 'value1' },
                                  'key2' => { type: 'integer', value: '2' }
                                })
      end
    end
  end
end

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

require 'chef/knife/cloud/exceptions'
require 'chef/knife/cloud/service'
require 'chef/knife/cloud/helpers'
require 'chef/knife/cloud/vra_service_helpers'
require 'vra'

class Chef
  class Knife
    class Cloud
      class VraService < Service
        include VraServiceHelpers
        def initialize(options={})
          super(options)

          @username   = options[:username]
          @password   = options[:password]
          @base_url   = options[:base_url]
          @tenant     = options[:tenant]
          @verify_ssl = options[:verify_ssl]
        end

        def connection
          @client ||= Vra::Client.new(
            base_url:   @base_url,
            username:   @username,
            password:   @password,
            tenant:     @tenant,
            verify_ssl: @verify_ssl
          )
        end

        def create_server(options={})
          submitted_request = catalog_request(options).submit
          ui.msg("Catalog request #{submitted_request.id} submitted.")
          wait_for_request(submitted_request, options[:wait_time], options[:refresh_rate])
          ui.msg("Catalog request complete.\n")
          request_summary(submitted_request)

          raise CloudExceptions::ServerCreateError, submitted_request.completion_details if submitted_request.failed?

          servers = submitted_request.resources.select(&:vm?)
          raise CloudExceptions::ServerCreateError, 'The vRA request created more than one server, but we were only expecting 1' if servers.length > 1
          raise CloudExceptions::ServerCreateError, 'The vRA request did not create any servers' if servers.length == 0

          servers.first
        end

        def delete_server(instance_id)
          server = get_server(instance_id)
          server_summary(server)
          ui.msg('')

          if server.status == 'DELETED'
            ui.warn("Server is already deleted.\n")
            return
          end

          ui.confirm('Do you really want to delete this server')

          destroy_request = server.destroy
          ui.msg("Destroy request #{destroy_request.id} submitted.")
          wait_for_request(destroy_request)
          ui.msg('Destroy request complete.')
          request_summary(destroy_request)
        end

        def list_servers
          connection.resources.all_resources.select(&:vm?)
        end

        def list_catalog_items(entitled)
          if entitled
            connection.catalog.entitled_items
          else
            connection.catalog.all_items
          end
        end

        def get_server(instance_id)
          connection.resources.by_id(instance_id)
        end

        def server_summary(server, _columns_with_info=nil)
          msg_pair('Server ID', server.id)
          msg_pair('Server Name', server.name)
          msg_pair('IP Addresses', server.ip_addresses.nil? ? 'none' : server.ip_addresses.join(', '))
          msg_pair('Status', server.status)
          msg_pair('Catalog Name', server.catalog_name)
        end

        def request_summary(request)
          ui.msg('')
          msg_pair('Request Status', request.status)
          msg_pair('Completion State', request.completion_state)
          msg_pair('Completion Details', request.completion_details)
          ui.msg('')
        end

        def catalog_request(options)
          catalog_request = connection.catalog.request(options[:catalog_id])

          catalog_request.cpus          = options[:cpus]
          catalog_request.memory        = options[:memory]
          catalog_request.requested_for = options[:requested_for]
          catalog_request.lease_days    = options[:lease_days]    unless options[:lease_days].nil?
          catalog_request.notes         = options[:notes]         unless options[:notes].nil?
          catalog_request.subtenant_id  = options[:subtenant_id]  unless options[:subtenant_id].nil?

          if options[:vra_extra_params]
            options[:vra_extra_params].each do |key, value_data|
              catalog_request.set_parameter(key, value_data[:type], value_data[:value])
            end
          end

          catalog_request
        end
      end
    end
  end
end

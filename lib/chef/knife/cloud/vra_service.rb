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

require "chef/knife/cloud/exceptions"
require "chef/knife/cloud/service"
require "chef/knife/cloud/helpers"
require_relative "vra_service_helpers"
require "vra"

class Chef
  class Knife
    class Cloud
      class VraService < Service
        include VraServiceHelpers
        def initialize(options = {})
          super(config: options)

          @username   = options[:username]
          @password   = options[:password]
          @base_url   = options[:base_url]
          @tenant     = options[:tenant]
          @verify_ssl = options[:verify_ssl]
          @page_size  = options[:page_size]
        end

        def connection
          @client ||= Vra::Client.new(
            base_url:   @base_url,
            username:   @username,
            password:   @password,
            tenant:     @tenant,
            page_size:  @page_size,
            verify_ssl: @verify_ssl
          )
        end

        def create_server(options = {})
          submitted_request = catalog_request(options).submit
          ui.msg("Catalog request #{submitted_request.id} submitted.")
          wait_for_request(submitted_request, (options[:wait_time] || 600).to_i, options[:refresh_rate] || 2)
          ui.msg("Catalog request complete.\n")
          request_summary(submitted_request)

          raise CloudExceptions::ServerCreateError if submitted_request.failed?

          servers = submitted_request.resources.select(&:vm?)
          raise CloudExceptions::ServerCreateError, "The vRA request created more than one server, but we were only expecting 1" if servers.length > 1
          raise CloudExceptions::ServerCreateError, "The vRA request did not create any servers" if servers.length == 0

          servers.first
        end

        def delete_server(deployment_id)
          deployment = get_deployment(deployment_id)
          server = deployment.resources.select(&:vm?).first
          server_summary(server)
          ui.msg("")

          if server.status == "DELETED"
            ui.warn("Server is already deleted.\n")
            return
          end

          ui.confirm("Do you really want to delete this server")

          destroy_request = deployment.destroy
          ui.msg("Destroy request #{destroy_request.id} submitted.")
          wait_for_request(destroy_request)
          ui.msg("Destroy request complete.")
          request_summary(destroy_request)
        end

        def list_servers
          connection.deployments.all
        end

        def list_catalog_items(project_id, entitled)
          if entitled
            connection.catalog.entitled_items(project_id)
          else
            connection.catalog.all_items
          end
        end

        def get_deployment(deployment_id)
          connection.deployments.by_id(deployment_id)
        end

        def get_server(deployment_id)
          deployment = connection.deployments.by_id(deployment_id)
          deployment.resources.select(&:vm?).first
        end

        def server_summary(server, _columns_with_info = nil)
          deployment = connection.deployments.by_id(server.deployment_id)
          msg_pair("Deployment ID", deployment.id)
          msg_pair("Deployment Name", deployment.name)
          msg_pair("IP Address", server.ip_address.nil? ? "none" : server.ip_address)
          msg_pair("Status", server.status)
          msg_pair("Owner Names", server.owner_names.empty? ? "none" : server.owner_names)
        end

        def request_summary(request)
          ui.msg("")
          msg_pair("Request Status", request.status)
          ui.msg("")
        end

        def catalog_request(options)
          catalog_request = connection.catalog.request(options[:catalog_id])

          catalog_request.image_mapping  = options[:image_mapping]
          catalog_request.flavor_mapping = options[:flavor_mapping]
          catalog_request.name           = options[:name]
          catalog_request.project_id     = options[:project_id]
          catalog_request.version        = options[:version] unless options[:version].nil?

          options[:extra_params]&.each do |param|
            catalog_request.set_parameter(param[:key], param[:type], param[:value])
          end
          # rubocop:enable all

          catalog_request
        end
      end
    end
  end
end

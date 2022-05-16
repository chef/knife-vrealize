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

require "chef/knife"
require "chef/knife/cloud/server/create_command"
require "chef/knife/cloud/server/create_options"
require_relative "cloud/vra_service_options"
require_relative "cloud/vra_service_helpers"

class Chef
  class Knife
    class Cloud
      class VraServerCreate < ServerCreateCommand
        include VraServiceOptions
        include ServerCreateOptions
        include VraServiceHelpers

        banner "knife vra server create CATALOG_ID (options)"

        deps do
          require_relative "cloud/vra_service"
        end

        option :project_id,
          long:        "--project-id PROJECT_ID",
          description: "ID of the project"

        option :image_mapping,
          long:        "--image-mapping IMAGE_MAPPING",
          description: "Specifies the OS image for the new VM"

        option :server_create_timeout,
          long:        "--server-create-timeout SECONDS",
          description: "number of seconds to wait for the server to complete",
          default:     600

        option :flavor_mapping,
          long:        "--flavor-mapping FLAVOR_MAPPING",
          description: "Specifies the CUP count and RAM for the new VM"

        option :version,
          long:        "--version VERSION",
          description: "Specifies the version of the catalog to be used. By default the latest version will be used."

        option :name,
          long:        "--name NAME",
          description: "Name for the newly created deployment"

        option :extra_params,
          long:        "--extra-param KEY=TYPE:VALUE",
          description: 'Additional parameters to pass to vRA for this catalog request. TYPE must be "string" or "integer". ' \
            "Can be used multiple times.",
          default:     {},
          proc:        proc { |param|
            Chef::Config[:knife][:vra_extra_params] ||= {}
            key, value_str = param.split("=")
            Chef::Config[:knife][:vra_extra_params].merge!(key => value_str)
          }

        def validate_params!
          super

          if @name_args.empty?
            ui.error("You must supply a Catalog ID to use for your new server.")
            exit 1
          end

          check_for_missing_config_values!(:name, :flavor_mapping, :image_mapping, :project_id)

          validate_extra_params!
        end

        def before_exec_command
          super

          @create_options = {
            catalog_id: @name_args.first,
            project_id: config[:project_id],
            image_mapping: config[:image_mapping],
            flavor_mapping: config[:flavor_mapping],
            version: config[:version],
            name: config[:name],
            extra_params: extra_params,
          }
        end

        def before_bootstrap
          super

          config[:chef_node_name] ||= server.name
          config[:bootstrap_ip_address] = hostname_for_server
        end

        def extra_params
          return if Chef::Config[:knife][:vra_extra_params].nil? || Chef::Config[:knife][:vra_extra_params].empty?

          Chef::Config[:knife][:vra_extra_params].each_with_object([]) do |(key, value_str), memo|
            type, value = value_str.split(":")
            memo << { key: key, type: type, value: value }
          end
        end

        def validate_extra_params!
          return if extra_params.nil?

          extra_params.each do |param|
            raise ArgumentError, "No type and value set for extra parameter #{param[:key]}" if param[:type].nil? || param[:value].nil?
            raise ArgumentError, "Invalid parameter type for #{param[:key]} - must be string or integer" unless
              param[:type] == "string" || param[:type] == "integer"
          end
        end

        def hostname_for_server
          ip_address = server.ip_address

          ip_address.nil? ? server.name : ip_address
        end
      end
    end
  end
end

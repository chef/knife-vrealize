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
require "chef/knife/cloud/list_resource_command"
require_relative "cloud/vra_service_options"

class Chef
  class Knife
    class Cloud
      class VraCatalogList < ResourceListCommand
        include VraServiceOptions

        banner "knife vra catalog list"

        deps do
          require_relative "cloud/vra_service"
          require_relative "cloud/vra_service_helpers"
          include VraServiceHelpers
        end

        option :project_id,
          long:        "--project-id",
          description: "Catalogs are retrieved using the Project ID"

        option :entitled,
          long:        "--entitled-only",
          description: "only list entitled vRA catalog entries",
          boolean:     true,
          default:     false

        def before_exec_command
          @columns_with_info = [
            { label: "Catalog ID",  key: "id" },
            { label: "Name",        key: "name" },
            { label: "Description", key: "description" },
            { label: "Source",      key: "source_name" },
          ]

          @sort_by_field = "name"
        end

        def query_resource
          @service.list_catalog_items(config[:project_id], config[:entitled])
        end

        def format_status_value(status)
          return "-" if status.nil?

          status = status.downcase
          color  = if status == "published"
                     :green
                   else
                     :red
                   end

          ui.color(status, color)
        end
      end
    end
  end
end

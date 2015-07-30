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

require 'chef/knife'
require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/cloud/vra_service'
require 'chef/knife/cloud/vra_service_helpers'
require 'chef/knife/cloud/vra_service_options'

class Chef
  class Knife
    class Cloud
      class VraCatalogList < ResourceListCommand
        include VraServiceHelpers
        include VraServiceOptions

        banner 'knife vra catalog list'

        option :entitled,
               long:        '--entitled-only',
               description: 'only list entitled vRA catalog entries',
               boolean:     true,
               default:     false

        def before_exec_command
          @columns_with_info = [
            { label: 'Catalog ID',  key: 'id' },
            { label: 'Name',        key: 'name' },
            { label: 'Description', key: 'description' },
            { label: 'Status',      key: 'status', value_callback: method(:format_status_value) },
            { label: 'Subtenant',   key: 'subtenant_name' }
          ]

          @sort_by_field = 'name'
        end

        def query_resource
          @service.list_catalog_items(locate_config_value(:entitled))
        end

        def format_status_value(status)
          status = status.downcase
          if status == 'published'
            color = :green
          else
            color = :red
          end

          ui.color(status, color)
        end
      end
    end
  end
end

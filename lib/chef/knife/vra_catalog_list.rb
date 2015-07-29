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

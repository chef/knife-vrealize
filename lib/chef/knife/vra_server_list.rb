require 'chef/knife'

require 'chef/knife/cloud/server/list_command'
require 'chef/knife/cloud/server/list_options'
require 'chef/knife/cloud/vra_service'
require 'chef/knife/cloud/vra_service_helpers'
require 'chef/knife/cloud/vra_service_options'

class Chef
  class Knife
    class Cloud
      class VraServerList < ServerListCommand
        include VraServiceHelpers
        include VraServiceOptions

        banner 'knife vra server list'

        def before_exec_command
          @columns_with_info = [
            { label: 'Resource ID',  key: 'id' },
            { label: 'Name',         key: 'name' },
            { label: 'Status',       key: 'status', value_callback: method(:format_status_value) },
            { label: 'Catalog Name', key: 'catalog_name' }
          ]

          @sort_by_field = 'name'
        end

        def format_status_value(status)
          status = status.downcase
          status_color = case status
                         when 'active'
                           :green
                         when 'deleted'
                           :red
                         else
                           :yellow
                         end
          ui.color(status, status_color)
        end
      end
    end
  end
end

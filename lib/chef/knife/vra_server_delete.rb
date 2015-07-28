require 'chef/knife'
require 'chef/knife/cloud/server/delete_options'
require 'chef/knife/cloud/server/delete_command'
require 'chef/knife/cloud/vra_service'
require 'chef/knife/cloud/vra_service_helpers'
require 'chef/knife/cloud/vra_service_options'

class Chef
  class Knife
    class Cloud
      class VraServerDelete < ServerDeleteCommand
        include ServerDeleteOptions
        include VraServiceHelpers
        include VraServiceOptions

        banner 'knife vra server delete RESOURCE_ID [RESOURCE_ID] (options)'

        # overriding this method from knife-cloud so we can pull the machine name
        # to pass to delete_from_chef rather than the resource ID
        def execute_command
          @name_args.each do |resource_id|
            server = service.get_server(resource_id)
            service.delete_server(resource_id)
            delete_from_chef(server.name)
          end
        end
      end
    end
  end
end

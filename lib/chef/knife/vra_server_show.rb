require 'chef/knife'
require 'chef/knife/cloud/server/show_options'
require 'chef/knife/cloud/server/show_command'
require 'chef/knife/cloud/vra_service'
require 'chef/knife/cloud/vra_service_helpers'
require 'chef/knife/cloud/vra_service_options'

class Chef
  class Knife
    class Cloud
      class VraServerShow < ServerShowCommand
        include ServerShowOptions
        include VraServiceHelpers
        include VraServiceOptions

        banner 'knife vra server show RESOURCE_ID (options)'
      end
    end
  end
end

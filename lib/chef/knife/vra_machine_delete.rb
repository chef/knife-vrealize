require 'chef/knife'
require 'chef/knife/vrealize_base'
require 'chef/knife/vra_base'

module KnifeVrealize
  class VraMachineDelete < Chef::Knife
    include KnifeVrealize::Base
    include KnifeVrealize::VraBase

    banner 'knife vra machine delete MACHINE_ID [MACHINE_ID] [MACHINE_ID]'

    option :purge,
      :short => "-P",
      :long => "--purge",
      :boolean => true,
      :default => false,
      :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the vRA resource itself.  Assumes node and client have the same name as the machine (if not, add the '--node-name' option)."

    option :chef_node_name,
      :short => "-N NAME",
      :long => "--node-name NAME",
      :description => "The name of the node and client to delete, if it differs from the server name.  Only has meaning when used with the '--purge' option."

    def destroy_item(klass, name, type_name)
      begin
        object = klass.load(name)
        object.destroy
        puts "Deleted #{type_name} #{name}"
      rescue Net::HTTPServerException
        ui.warn("Could not find a #{type_name} named #{name} to delete!")
      end
    end

    def run
      validate_required_config!

      if @name_args.empty?
        ui.error('You must specify at least one machine you would like to destroy.')
        exit 1
      end

      @name_args.each do |machine_id|
        begin
          resource = vra_client.resources.by_id(machine_id)
        rescue Vra::Exception::NotFound
          ui.error("Unable to find vRA resource with ID: #{machine_id}")
          next
        rescue => e
          ui.error("Error while looking up vRA resource ID #{machine_id}: #{e.message}")
          next
        end

        if resource.status == 'DELETED'
          ui.warn("Machine #{resource.name} (#{machine_id}) is already deleted.")
          next
        end

        msg_pair('Machine ID', machine_id)
        msg_pair('Machine Name', resource.name)
        msg_pair('Machine Status', resource.status)
        msg_pair('Catalog Name', resource.catalog_name)
        msg_pair('IP Addresses', resource.ip_addresses.join(', ')) unless resource.ip_addresses.nil?

        puts "\n"
        confirm('Do you really want to delete this server')

        destroy_request = resource.destroy
        puts "Destroy request #{destroy_request.id} for #{resource.name} (#{machine_id}) submitted."

        wait_for_request(destroy_request)
        
        puts "Destroy request complete.  Status: #{destroy_request.status}."

        if get_config_value(:purge)
          object_name = get_config_value(:chef_node_name) || resource.name
          puts "Deleting node and client objects for #{object_name} on Chef Server..."

          destroy_item(Chef::Node, object_name, 'node')
          destroy_item(Chef::ApiClient, object_name, 'client')
        else
          puts "No Chef Server node or client deleted for #{resource.name} since --purge was not specified."
        end
      end
    end
  end
end

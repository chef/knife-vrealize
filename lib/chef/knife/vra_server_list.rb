require 'chef/knife'

module KnifeVrealize
  class VraServerList < Chef::Knife
    include KnifeVrealize::Base
    include KnifeVrealize::VraBase

    banner 'knife vra server list'

    def run
      validate_required_config!

      servers = vra_client.resources.all_resources
      servers.select! { |x| x.vm? }

      if servers.empty?
        ui.warn('No servers found.')
        exit 1
      end

      server_list = [
        ui.color('Name', :bold),
        ui.color('Resource ID', :bold),
        ui.color('Status', :bold),
        ui.color('Catalog Name', :bold)
      ]

      servers.sort { |a, b| a.name <=> b.name }.each do |server|
        server_list << server.name
        server_list << server.id
        server_list << server.status
        server_list << server.catalog_name
      end

      puts ui.list(server_list, :uneven_columns_across, 4)
    end
  end
end

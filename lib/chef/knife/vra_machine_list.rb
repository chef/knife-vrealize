module KnifeVrealize
  class VraMachineList < Chef::Knife
    include KnifeVrealize::Base
    include KnifeVrealize::VraBase

    banner 'knife vra machine list'

    def run
      validate_required_config!

      machines = vra_client.resources.all_resources
      machines.select! { |x| x.vm? }

      if machines.empty?
        ui.warn('No machines found.')
        exit 1
      end

      machine_list = [
        ui.color('Resource ID', :bold),
        ui.color('Name', :bold),
        ui.color('Status', :bold),
        ui.color('Catalog Name', :bold)
      ]

      machines.each do |machine|
        machine_list << machine.id
        machine_list << machine.name
        machine_list << machine.status
        machine_list << machine.catalog_name
      end

      puts ui.list(machine_list, :uneven_columns_across, 4)
    end
  end
end

require 'chef/knife'
require 'chef/knife/vrealize_base'
require 'chef/knife/vra_base'

module KnifeVrealize
  class VraServerCreate < Chef::Knife
    include KnifeVrealize::Base
    include KnifeVrealize::VraBase

    banner 'knife vra server create CATALOG_ID (options)'

    option :cpus,
      long:        '--cpus NUM_CPUS',
      description: 'Number of CPUs the server should have',
      required:    true

    option :memory,
      long:        '--memory RAM_IN_MB',
      description: 'Amount of RAM, in MB, the server should have',
      required:    true

    option :requested_for,
      long:        '--requested-for LOGIN',
      description: 'The login to list as the owner of this resource.  Will default to the vra_username parameter',
      required:    true

    option :subtenant_id,
      long:        '--subtenant-id ID',
      description: 'The subtenant ID (a.k.a "business group") to list as the owner of this resource.  Will default to the blueprint subtenant if it exists.'

    option :lease_days,
      long:        '--lease-days NUM_DAYS',
      description: 'Number of days requested for the server lease, provided the blueprint allows this to be specified'

    option :notes,
      long:        '--notes NOTES',
      description: 'String of text to be included in the request notes.'

    option :extra_params,
      long:        '--extra-params KEY1=TYPE:VALUE1[,KEY2=TYPE:VALUE2],...',
      description: 'Additional parameters to pass to vRA for this catalog request.  TYPE must be "string" or "integer" and unfortunately vRA cannot determine this on its own.',
      default:     [],
      proc:        Proc.new { |params| params.split(',') }

    option :skip_bootstrap,
      long:        '--skip-bootstrap',
      description: 'Disable bootstrap of server after creation.  This is helpful if your vRA blueprint already ensures Chef is installed and registered.',
      boolean:     true,
      default:     false

    def build_catalog_request
      catalog_request = vra_client.catalog.request(@name_args.first)

      catalog_request.cpus          = get_config_value(:cpus)
      catalog_request.memory        = get_config_value(:memory)
      catalog_request.requested_for = get_config_value(:requested_for)
      catalog_request.lease_days    = get_config_value(:lease_days)    unless get_config_value(:lease_days).nil?
      catalog_request.notes         = get_config_value(:notes)         unless get_config_value(:notes).nil?
      catalog_request.subtenant_id  = get_config_value(:subtenant_id)  unless get_config_value(:subtenant_id).nil?

      get_config_value(:extra_params).each do |param|
        key, value_data = param.split('=')
        type, value = value_data.split(':')

        unless key && type && value
          ui.error("extra parameter did not include key, type, and value: #{param}")
          exit 1
        end

        catalog_request.set_parameter(key, type, value)
      end

      catalog_request
    end

    def bootstrap_server(server)
      puts "Beginning bootstrap of #{server.name}..."

      puts "Bootstrap of #{server.name} complete."
    end

    def run
      if @name_args.empty?
        ui.error('You must specify a catalog ID from which to create a server.')
        exit 1
      end

      catalog_request = build_catalog_request

      submitted_request = catalog_request.submit
      puts "Catalog request #{submitted_request.id} submitted."
      wait_for_request(submitted_request)
      puts "Catalog request complete.\n"

      msg_pair('Request Status', submitted_request.status)
      msg_pair('Completion State', submitted_request.completion_state)
      msg_pair('Completion Details', submitted_request.completion_details)

      exit 1 if submitted_request.failed?

      servers = submitted_request.resources.select { |resource| resource.vm? }
      if servers.length == 0
        ui.error("No server resources were created as part of your request.  Check the vRA UI for more information.")
        exit 1
      end

      servers.each do |server|
        msg_pair('Server Name', server.name)
        msg_pair('Server Primary IP Address', server.ip_addresses.first)
        bootstrap_server(server) unless get_config_value(:skip_bootstrap)

        puts "\n"
      end
    end
  end
end

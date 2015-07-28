require 'chef/knife'

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/cloud/server/create_options'
require 'chef/knife/cloud/vra_service'
require 'chef/knife/cloud/vra_service_helpers'
require 'chef/knife/cloud/vra_service_options'

class Chef
  class Knife
    class Cloud
      class VraServerCreate < ServerCreateCommand
        include VraServiceHelpers
        include VraServiceOptions
        include ServerCreateOptions

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
          long:        '--extra-param KEY=TYPE:VALUE',
          description: 'Additional parameters to pass to vRA for this catalog request.  TYPE must be "string" or "integer" and unfortunately vRA cannot determine this on its own.  Can be used multiple times.',
          default:     {},
          proc:        Proc.new { |param| 
                         Chef::Config[:knife][:vra_extra_params] ||= {}
                         key, value_str = param.split('=')
                         Chef::Config[:knife][:vra_extra_params].merge!({key => value_str})
                       }
        
        def validate_params!
          super

          if @name_args.empty?
            ui.error("You must supply a Catalog ID to use for your new server.")
            exit 1
          end

          validate_extra_params!
        end

        def before_exec_command
          super

          @create_options = {
            catalog_id:       @name_args.first,
            cpus:             locate_config_value(:cpus),
            memory:           locate_config_value(:memory),
            requested_for:    locate_config_value(:requested_for),
            subtenant_id:     locate_config_value(:subtenant_id),
            lease_days:       locate_config_value(:lease_days),
            notes:            locate_config_value(:notes),
            extra_params:     extra_params,
            wait_time:        locate_config_value(:server_create_timeout),
            refresh_rate:     locate_config_value(:request_refresh_rate)
          }
        end

        def before_bootstrap
          super

          config[:chef_node_name] = locate_config_value(:chef_node_name) ? locate_config_value(:chef_node_name) : server.name
          config[:bootstrap_ip_address] = server.ip_addresses.first
        end

        def extra_params
          return unless Chef::Config[:knife][:vra_extra_params]

          params = []
          Chef::Config[:knife][:vra_extra_params].each do |key, value_str|
            type, value = value_str.split(':')
            params << { key: key, type: type, value: value }
          end

          params
        end

        def validate_extra_params!
          return if extra_params.nil?

          extra_params.each do |param|
            raise ArgumentError, "No type and value set for extra parameter #{param[:key]}" if param[:type].nil? || param[:value].nil?
            raise ArgumentError, "Invalid parameter type for #{param[:key]} - must be string or integer" unless param[:type] == 'string' || param[:type] == 'integer'
          end
        end
      end
    end
  end
end

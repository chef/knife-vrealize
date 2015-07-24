module KnifeVrealize
  module VraBase
    def self.included(includer)
      includer.class_eval do
        deps do
          require 'vra'
        end

        option :vra_base_url, 
          long:        '--vra-base-url API_URL',
          description: 'URL for the vRA server'

        option :vra_username,
          long:        '--vra-username USERNAME',
          description: 'Username to use with the vRA API'

        option :vra_password,
          long:        '--vra-password PASSWORD',
          description: 'Password to use with the vRA API'

        option :vra_disable_ssl_verify,
          long:        '--vra-disable-ssl-verify',
          description: 'Skip any SSL verification for the vRA API',
          boolean:     true,
          default:     false
      end

      def verify_ssl?
        ! get_config_value(:vra_disable_ssl_verify)
      end

      def vra_client
        @client ||= Vra::Client.new(
          base_url:   get_config_value(:vra_base_url),
          username:   get_config_value(:vra_username),
          password:   get_config_value(:vra_password),
          tenant:     get_config_value(:vra_tenant),
          verify_ssl: verify_ssl?
        )
      end

      def validate_required_config!(additional_opts=[])
        additional_opts = [additional_opts] unless additional_opts.is_a?(Array)

        required_opts = [ :vra_base_url, :vra_username, :vra_password, :vra_tenant ] + additional_opts
        missing_opts  = Array.new

        required_opts.each do |opt|
          if get_config_value(opt).nil?
            missing_opts << opt
          end
        end

        if missing_opts.length > 0
          ui.error("The following config options are required: #{missing_opts.join(', ')}")
          exit 1
        end
      end
    end
  end
end

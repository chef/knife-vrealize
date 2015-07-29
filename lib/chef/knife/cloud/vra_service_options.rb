require 'chef/knife/cloud/fog/options'

class Chef
  class Knife
    class Cloud
      # rubocop:disable Style/AlignParameters
      module VraServiceOptions
        def self.included(includer)
          includer.class_eval do
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

            option :request_refresh_rate,
              long:        '--request-refresh-rate SECS',
              description: 'Number of seconds to sleep between each check of the request status, defaults to 2',
              default:     2,
              proc:        proc { |secs| secs.to_i }
          end
        end
      end
    end
  end
end

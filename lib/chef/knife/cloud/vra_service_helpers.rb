require 'chef/knife/cloud/helpers'

class Chef
  class Knife
    class Cloud
      module VraServiceHelpers
        include Chef::Knife::Cloud::Helpers

        def create_service_instance
          Chef::Knife::Cloud::VraService.new(username: locate_config_value(:vra_username),
                                             password: locate_config_value(:vra_password),
                                             base_url: locate_config_value(:vra_base_url),
                                             tenant:   locate_config_value(:vra_tenant),
                                             verify_ssl: verify_ssl?)
        end

        def verify_ssl?
          !locate_config_value(:vra_disable_ssl_verify)
        end

        def wait_for_request(request, wait_time=600, refresh_rate=2)
          print 'Waiting for request to complete.'

          last_status  = ''

          begin
            Timeout.timeout(wait_time) do
              loop do
                request.refresh

                if request.completed?
                  print "\n"
                  break
                end

                if last_status == request.status
                  print '.'
                else
                  last_status = request.status
                  print "\n"
                  print "Current request status: #{request.status}."
                end

                sleep refresh_rate
              end
            end
          rescue Timeout::Error
            ui.msg('')
            ui.error("Request did not complete in #{wait_time} seconds.")
            exit 1
          rescue
            # re-raise any non-timeout-related error
            raise
          end
        end
      end
    end
  end
end

#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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

            option :vra_page_size,
              long:        '--page-size NUM_OF_ITEMS',
              description: 'Maximum number of items to fetch from the vRA API when pagination is forced',
              default:     200,
              proc:        proc { |page_size| page_size.to_i }

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

# frozen_string_literal: true

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

        def validate_params!
          if @name_args.empty?
            ui.error('You must supply a Resource ID for a server to display.')
            exit 1
          end

          if @name_args.size > 1
            ui.error('You may only supply one Resource ID.')
            exit 1
          end

          super
        end
      end
    end
  end
end

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
require 'vcoworkflows'

class Chef
  class Knife
    # rubocop:disable Metrics/ClassLength
    # rubocop:disable Style/AlignParameters
    class VroWorkflowExecute < Chef::Knife
      attr_accessor :workflow_id, :workflow_name, :parameters

      include Chef::Knife::Cloud::Helpers

      banner 'knife vro workflow execute WORKFLOW_NAME [KEY=VALUE] [KEY=VALUE] (options)'

      option :vro_base_url,
        long:        '--vro-base-url API_URL',
        description: 'URL for the vro server'

      option :vro_username,
        long:        '--vro-username USERNAME',
        description: 'Username to use with the vro API'

      option :vro_password,
        long:        '--vro-password PASSWORD',
        description: 'Password to use with the vro API'

      option :vro_disable_ssl_verify,
        long:        '--vro-disable-ssl-verify',
        description: 'Skip any SSL verification for the vro API',
        boolean:     true,
        default:     false

      option :vro_workflow_id,
        long:        '--vro-workflow-id WORKFLOW_ID',
        description: 'ID of the workflow to execute'

      option :request_timeout,
        long:        '--request-timeout SECONDS',
        description: 'number of seconds to wait for the workflow to complete',
        default:     300

      def verify_ssl?
        !locate_config_value(:vro_disable_ssl_verify)
      end

      def vro_config
        @vro_config ||= VcoWorkflows::Config.new(
          url: locate_config_value(:vro_base_url),
          username: locate_config_value(:vro_username),
          password: locate_config_value(:vro_password),
          verify_ssl: verify_ssl?
        )
      end

      def vro_client
        @client ||= VcoWorkflows::Workflow.new(
          workflow_name,
          id: workflow_id,
          config: vro_config
        )
      end

      def parse_and_validate_params!(args)
        args.each_with_object({}) do |arg, memo|
          key, value = arg.split('=')
          raise "Invalid parameter, must be in KEY=VALUE format: #{arg}" if key.nil? || value.nil?

          memo[key] = value
        end
      end

      def execute_workflow
        parameters.each do |key, value|
          vro_client.parameter(key, value)
        end
        begin
          vro_client.execute
        rescue RestClient::BadRequest => e
          ui.error("The workflow execution request failed: #{e.response}")
          raise
        rescue => e
          ui.error("The workflow execution request failed: #{e.message}")
          raise
        end
      end

      def wait_for_workflow
        wait_time = locate_config_value(:request_timeout)
        Timeout.timeout(wait_time) do
          loop do
            token = vro_client.token
            break unless token.alive?

            sleep 2
          end
        end
      rescue Timeout::Error
        raise Timeout::Error, "Workflow did not complete in #{wait_time} seconds. Please check the vRO UI for more information."
      end

      def missing_config_parameters
        [:vro_username, :vro_password, :vro_base_url].each_with_object([]) do |param, memo|
          memo << param if locate_config_value(param).nil?
        end
      end

      def validate!
        print_error_and_exit('The following parameters are missing but required:' \
          "#{missing_config_parameters.join(', ')}") unless missing_config_parameters.empty?

        print_error_and_exit('You must supply a workflow name.') if @name_args.empty?
      end

      def print_error_and_exit(msg)
        ui.error(msg)
        exit(1)
      end

      def print_results
        ui.msg('')
        print_output_parameters
        print_execution_log
      end

      def print_output_parameters
        token = vro_client.token
        return if token.output_parameters.empty?

        ui.msg(ui.color('Output Parameters:', :bold))
        token.output_parameters.each do |k, v|
          msg_pair(k, "#{v.value} (#{v.type})") unless v.value.nil? || (v.value.respond_to?(:empty?) && v.value.empty?)
        end
        ui.msg('')
      end

      def print_execution_log
        log = vro_client.log.to_s
        return if log.nil? || log.empty?

        ui.msg(ui.color('Workflow Execution Log:', :bold))
        ui.msg(log)
      end

      def set_parameters
        self.workflow_name = @name_args.shift
        self.workflow_id   = locate_config_value(:vro_workflow_id)
        self.parameters    = parse_and_validate_params!(@name_args)
      end

      def run
        validate!

        set_parameters

        ui.msg('Starting workflow execution...')
        execution_id = execute_workflow

        ui.msg("Workflow execution #{execution_id} started. Waiting for it to complete...")
        wait_for_workflow

        ui.msg('Workflow execution complete.')

        print_results
      end
    end
  end
end

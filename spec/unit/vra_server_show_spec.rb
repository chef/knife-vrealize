require 'spec_helper'
require 'chef/knife/vra_server_show'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::VraServerShow do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraServerShow.new
end

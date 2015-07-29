require 'spec_helper'
require 'chef/knife/vra_server_create'
require 'support/shared_examples_for_command'
require 'support/shared_examples_for_servercreatecommand'

describe Chef::Knife::Cloud::VraServerCreate do
  argv = []
  argv += %w(--cpus 1)
  argv += %w(--memory 512)
  argv += %w(--requested-for myuser@corp.local)
  argv += %w(--bootstrap-protocol ssh)
  argv += %w(--ssh-password password)
  argv += %w(d5ba201a-449f-47a4-9d02-39196224bf01)
  argv += %w(--extra-param key1=string:value1)
  argv += %w(--extra-param key2=integer:2)

  subject { Chef::Knife::Cloud::VraServerCreate.new(argv) }

  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::VraServerCreate.new(argv)
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::VraServerCreate.new(argv)

  describe '#validate_params!' do
    context 'when no catalog ID is supplied' do
      it 'raises an error' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)

        command = Chef::Knife::Cloud::VraServerCreate.new(argv)
        expect(command.ui).to receive(:error)
        expect { command.validate_params! }.to raise_error(SystemExit)
      end
    end

    it 'validates extra parameters' do
      expect(subject).to receive(:validate_extra_params!)
      subject.validate_params!
    end
  end

  describe '#extra_params' do
    it 'parses extra parameters properly' do
      params = subject.extra_params
      expect(params[0][:key]).to eq 'key1'
      expect(params[0][:type]).to eq 'string'
      expect(params[0][:value]).to eq 'value1'
      expect(params[1][:key]).to eq 'key2'
      expect(params[1][:type]).to eq 'integer'
      expect(params[1][:value]).to eq '2'
    end
  end

  describe '#validate_extra_params!' do
    context 'when no extra parameters are supplied' do
      it 'does not raise an exception' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)
        command = Chef::Knife::Cloud::VraServerCreate.new(argv)

        expect { command.validate_extra_params! }.not_to raise_error
      end
    end

    context 'when correct parameters are supplied' do
      it 'does not raise an exception' do
        expect { subject.validate_extra_params! }.not_to raise_error
      end
    end

    context 'when a type or value is missing' do
      it 'raises an exception' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)
        argv += %w(d5ba201a-449f-47a4-9d02-39196224bf01)
        argv += %w(--extra-param key1=value1)
        command = Chef::Knife::Cloud::VraServerCreate.new(argv)

        expect { command.validate_extra_params! }.to raise_error(ArgumentError)
      end
    end

    context 'when an invalid parameter type is provided' do
      it 'raises an exception' do
        argv = []
        argv += %w(--cpus 1)
        argv += %w(--memory 512)
        argv += %w(--requested-for myuser@corp.local)
        argv += %w(--bootstrap-protocol ssh)
        argv += %w(--ssh-password password)
        argv += %w(d5ba201a-449f-47a4-9d02-39196224bf01)
        argv += %w(--extra-param key1=faketype:value1)
        command = Chef::Knife::Cloud::VraServerCreate.new(argv)

        expect { command.validate_extra_params! }.to raise_error(ArgumentError)
      end
    end
  end
end

module KnifeVrealize
  module Base
    def get_config_value(key)
      key = key.to_sym
      config[key] || Chef::Config[:knife][key]
    end
  end
end

module KnifeVrealize
  module Base
    def get_config_value(key)
      key = key.to_sym
      config[key] || Chef::Config[:knife][key]
    end

    def msg_pair(label, value, color=:cyan)
      if value && !value.to_s.empty?
        puts "#{ui.color(label, color)}: #{value}"
      end
    end
  end
end

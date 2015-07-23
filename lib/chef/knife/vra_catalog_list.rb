require 'chef/knife'

module KnifeVrealize
  class VraCatalogList < Chef::Knife
    include KnifeVrealize::VraBase

    banner 'knife vra catalog list'

    def run
      validate_required_config!
    end
  end
end

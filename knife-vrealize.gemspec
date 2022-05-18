# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "knife-vrealize/version"

Gem::Specification.new do |spec|
  spec.name          = "knife-vrealize"
  spec.version       = KnifeVrealize::VERSION
  spec.authors       = ["Chef Software"]
  spec.email         = ["oss@chef.io"]
  spec.summary       = "Chef Infra Knife plugin to interact with VMware vRealize."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/chef/knife-vrealize"
  spec.license       = "Apache-2.0"

  spec.files         = Dir["lib/**/*"] + %w{LICENSE}
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "knife"
  spec.add_dependency "knife-cloud",  ">= 1.2.0", "< 5.0"
  spec.add_dependency "vmware-vra",   "~> 2", "< 3" # 3 and above is not supported for this version of vRA
  spec.add_dependency "vcoworkflows", "~> 0.2"
  spec.add_dependency "rb-readline", "~> 0.5"
end

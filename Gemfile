source "https://rubygems.org"

gemspec

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
end

group :test do
  gem "chef"
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6")
    gem "chef-zero", "~> 14"
  end
  gem "chefstyle", "~> 0.15"
  gem "rake", ">= 10.0"
  gem "rspec", "~> 3.0"
end

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

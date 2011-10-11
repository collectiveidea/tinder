# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'tinder/version'

Gem::Specification.new do |gem|
  gem.add_development_dependency 'fakeweb', '~> 1.3'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_runtime_dependency 'activesupport', ['>= 2.3', '< 4']
  gem.add_runtime_dependency 'eventmachine', '~> 0.12'
  gem.add_runtime_dependency 'faraday', ['>= 0.6', '< 0.8']
  gem.add_runtime_dependency 'faraday_middleware', ['>= 0.6', '< 0.8']
  gem.add_runtime_dependency 'hashie', '~> 1.0'
  gem.add_runtime_dependency 'mime-types', '~> 1.16'
  gem.add_runtime_dependency 'multi_json', '~> 1.0'
  gem.add_runtime_dependency 'multipart-post', '~> 1.1'
  gem.add_runtime_dependency 'twitter-stream', '~> 0.1'

  gem.authors = ["Brandon Keepers", "Brian Ryckbost"]
  gem.description = %q{A Ruby API for interfacing with Campfire, the 37Signals chat application.}
  gem.email = ['brandon@opensoul.org']
  gem.extra_rdoc_files = ['README.markdown']
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'http://github.com/collectiveidea/tinder'
  gem.name = 'tinder'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  gem.summary = %q{Ruby wrapper for the Campfire API}
  gem.test_files = `git ls-files -- spec/*`.split("\n")
  gem.version = Tinder::VERSION
end

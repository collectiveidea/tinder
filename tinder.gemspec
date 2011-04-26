# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tinder/version"

Gem::Specification.new do |s|
  s.name = %q{tinder}
  s.version = Tinder::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brandon Keepers"]
  s.description = %q{A Ruby API for interfacing with Campfire, the 37Signals chat application.}
  s.email = %q{brandon@opensoul.org}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.homepage = %q{http://github.com/collectiveidea/tinder}
  s.rubyforge_project = %q{tinder}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby wrapper for the Campfire API}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<faraday>, ["~> 0.5.1"])
      s.add_runtime_dependency(%q<multipart-post>, [">= 0"])
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
      s.add_runtime_dependency(%q<twitter-stream>, [">= 0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<faraday>, ["~> 0.5.1"])
      s.add_dependency(%q<multipart-post>, [">= 0"])
      s.add_dependency(%q<mime-types>, [">= 0"])
      s.add_dependency(%q<twitter-stream>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<faraday>, ["~> 0.5.1"])
    s.add_dependency(%q<multipart-post>, [">= 0"])
    s.add_dependency(%q<mime-types>, [">= 0"])
    s.add_dependency(%q<twitter-stream>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
  end
end


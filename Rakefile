require 'rubygems'
require 'hoe'
begin
  require 'spec/rake/spectask'
rescue LoadError
  puts 'To use rspec for testing you must install rspec gem:'
  puts '$ sudo gem install rspec'
  exit
end
require File.join(File.dirname(__FILE__), 'lib', 'tinder', 'version')

# RDOC_OPTS = ['--quiet', '--title', "Tinder",
#     "--opname", "index.html",
#     "--line-numbers", 
#     "--main", "README",
#     "--inline-source"]
# 
# Generate all the Rake tasks

hoe = Hoe.new('tinder', ENV['VERSION'] || Tinder::VERSION::STRING) do |p|
  p.rubyforge_name = 'tinder'
  p.summary = "An (unofficial) Campfire API"
  p.description = "An API for interfacing with Campfire, the 37Signals chat application."
  p.author = 'Brandon Keepers'
  p.email = 'brandon@opensoul.org'
  p.url = 'http://tinder.rubyforge.org'
  p.test_globs = ["test/**/*_test.rb"]
  p.changes = p.paragraphs_of('CHANGELOG.txt', 0..1).join("\n\n")
  p.extra_deps << ['activesupport']
  p.extra_deps << ['hpricot']
  p.extra_deps << ['mime-types']
end

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Default task is to run specs"
task :default => :spec

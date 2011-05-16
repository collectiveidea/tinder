require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
desc 'Run the specs'
RSpec::Core::RakeTask.new do |r|
  r.verbose = false
end

task :default => :spec

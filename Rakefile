begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "tinder"
    gem.summary = "Ruby wrapper for the Campfire API"
    gem.description = "A Ruby API for interfacing with Campfire, the 37Signals chat application."
    gem.authors = ['Brandon Keepers']
    gem.email = 'brandon@opensoul.org'
    gem.homepage = 'http://github.com/collectiveidea/tinder'
    gem.rubyforge_project = "tinder"
    gem.add_dependency "activesupport"
    gem.add_dependency "httparty"
    gem.add_dependency "mime-types"
    gem.add_dependency "twitter-stream"
    gem.add_dependency "eventmachine"
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "fakeweb"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tinder #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'spec/rake/spectask'
desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end
task :spec => :check_dependencies

task :default do
  %w(2.3.5 2.3.9 3.0.0).each do |version|
    puts "Running specs with Rails #{version}"
    system("RAILS_VERSION=#{version} rake -s spec;")
  end
end

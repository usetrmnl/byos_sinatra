# frozen_string_literal: true

require './app'
require 'sinatra/activerecord/rake'

desc 'Look for style guide offenses in your code'
task :rubocop do
  sh 'rubocop --format simple || true'
end

task default: %i[rubocop test:spec]

desc 'Open an irb session preloaded with the environment'
task :console do
  require 'rubygems'
  require 'pry'

  Pry.start
end

namespace :test do
  desc "Run tests"
  begin
    require 'rspec/core/rake_task'
    puts "Running rspec"
    RSpec::Core::RakeTask.new(:spec)
  rescue LoadError
    puts "RSpec not available"
  end
end

require 'fileutils'

namespace :plugins do
  desc "Download the last tagged set of OSS plugins"
  task :download do
    # Define paths
    plugin_dir = "plugins"
    
    # Ensure clean state
    FileUtils.rm_rf(plugin_dir) if File.exist?(plugin_dir)

    # having a specific release tag would be better once we get to that level of stability
    tag = "master"
    
    # Clone plugins - 
    sh "git clone --branch #{tag} --depth 1 https://github.com/usetrmnl/plugins/ #{plugin_dir}"
    
    puts "Plugins updated to #{tag}"
  end
end

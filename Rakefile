require './app'
require 'sinatra/activerecord/rake'

desc 'Look for style guide offenses in your code'
task :rubocop do
  sh 'rubocop --format simple || true'
end

task default: %i[rubocop spec]

desc 'Open an irb session preloaded with the environment'
task :console do
  require 'rubygems'
  require 'pry'

  Pry.start
end

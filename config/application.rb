# frozen_string_literal: true

require "dotenv/load"
require "sinatra"
require "sinatra/activerecord"
require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.push_dir "#{__dir__}/../app"
  loader.push_dir "#{__dir__}/../lib"
  loader.push_dir "#{__dir__}/../models"
  loader.push_dir "#{__dir__}/initializers"
  loader.tag = "trmnl-application"
  loader.setup
end

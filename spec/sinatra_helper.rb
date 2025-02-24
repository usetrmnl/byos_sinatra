# frozen_string_literal: true

ENV["APP_ENV"] = "test"
ENV["RACK_ENV"] = "test"

require "active_record"
require "capybara/cuprite"
require "capybara/rspec"
require "database_cleaner/active_record"
require "rack/test"
require "spec_helper"

require_relative "../app"

ActiveRecord::Base.establish_connection :test
ActiveRecord::Schema.verbose = false
load "db/schema.rb"

ENV["LD_PRELOAD"] = nil
Capybara.app = TRMNL::Application
Capybara.server = :puma, {Silent: true, Threads: "0:1"}
Capybara.javascript_driver = :cuprite
Capybara.save_path = Bundler.root.join "tmp/capybara"
Capybara.register_driver :cuprite do |app|
  browser_options = {"disable-gpu" => nil, "disable-dev-shm-usage" => nil, "no-sandbox" => nil}
  Capybara::Cuprite::Driver.new app, browser_options:, window_size: [1920, 1080]
end

using Refinements::Pathname

Pathname.require_tree SPEC_ROOT.join("support/shared_contexts/sinatra")

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL, Capybara::RSpecMatchers, :web
  config.include Rack::Test::Methods, type: :request

  config.after do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end

ENV['RACK_ENV'] = 'test'

require 'active_record'
require 'rack/test'
require 'nokogiri'
require_relative "../app"


# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include Rack::Test::Methods

  ActiveRecord::Base.establish_connection(:test)
  ActiveRecord::Schema.verbose = false
  load "db/schema.rb"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  def app
    Sinatra::Application
  end

  def get_and_parse(page, params={})
    get page, params
    doc = Nokogiri::HTML(last_response.body)
    return doc
  end
end

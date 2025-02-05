ENV['APP_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'

require 'active_record'
require 'rack/test'
require 'nokogiri'
require 'database_cleaner/active_record'
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

  DatabaseCleaner.strategy = :truncation
  config.after do 
    DatabaseCleaner.clean
  end

  def app
    Sinatra::Application
  end

  def get_and_parse(page, query_params={}, env={})
    get(page, query_params, env)
    @doc = Nokogiri::HTML(last_response.body)
    return @doc
  end

  def get_json(page, query_params={}, env={})
    get(page, query_params, env)
    @doc = last_response
    expect(@doc.headers['content-type']).to eq("application/json")
    return [@doc, JSON.parse(@doc.body)]
  end

  def post_json(page, data, params={}, env={})
    post(page, JSON.generate(data), params, env)
    @doc = last_response
    expect(@doc.headers['content-type']).to eq("application/json")
    return [@doc, JSON.parse(@doc.body)]
  end
end

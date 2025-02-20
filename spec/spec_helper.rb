# frozen_string_literal: true

require "simplecov"

unless ENV["NO_COVERAGE"]
  SimpleCov.start do
    add_filter %r(^/spec/)
    enable_coverage :branch
    enable_coverage_for_eval
    minimum_coverage_by_file line: 95, branch: 95
  end
end

ENV["APP_ENV"] = "test"
ENV["RACK_ENV"] = "test"

Bundler.require :tools

require "active_record"
require "database_cleaner/active_record"
require "nokogiri"
require "rack/test"
require "refinements"

require_relative "../app"

SPEC_ROOT = Pathname(__dir__).realpath.freeze

ActiveRecord::Base.establish_connection :test
ActiveRecord::Schema.verbose = false
load "db/schema.rb"

using Refinements::Pathname

Pathname.require_tree SPEC_ROOT.join("support/shared_contexts")

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.color = true
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "./tmp/rspec-examples.txt"
  config.filter_run_when_matching :focus
  config.formatter = ENV.fetch("CI", false) == "true" ? :progress : :documentation
  config.order = :random
  config.pending_failure_output = :no_backtrace
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end

  config.after do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  def app
    Sinatra::Application
  end

  def get_json page, query_params = {}, env = {}
    get page, query_params, env
    response = last_response
    JSON response.body, symbolize_names: true
  end

  # rubocop:todo Metrics/ParameterLists
  def post_json page, data, params = {}, env = {}
    post page, JSON.generate(data), params, env
    @doc = last_response
    expect(@doc.headers["content-type"]).to eq("application/json")
    [@doc, JSON.parse(@doc.body)]
  end
  # rubocop:enable Metrics/ParameterLists
end

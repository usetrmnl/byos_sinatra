# frozen_string_literal: true

require_relative "app"
Bundler.require :tools if ENV.fetch("RACK_ENV") == "development"

run TRMNL::Application

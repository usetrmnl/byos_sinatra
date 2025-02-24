# frozen_string_literal: true

ruby file: ".ruby-version"

source "https://rubygems.org"

gem "activerecord", "~> 8.0"
gem "dotenv", "~> 3.1"
gem "ferrum", "~> 0.15"
gem "forme", "~> 2.6"
gem "json", "~> 2.10"
gem "mini_magick", "~> 5.1"
gem "puma", "~> 6.6"
gem "rackup", "~> 2.2"
gem "refinements", "~> 13.0"
gem "sinatra-activerecord", "~> 2.0"
gem "sqlite3", "~> 2.5"

group :quality do
  gem "caliber", "~> 0.68"
  gem "git-lint", "~> 9.0"
  gem "reek", "~> 6.4", require: false
  gem "simplecov", "~> 0.22", require: false
end

group :development do
  gem "localhost", "~> 1.3"
  gem "rake", "~> 13.2"
end

group :test do
  gem "capybara", "~> 3.40"
  gem "cuprite", "~> 0.15"
  gem "database_cleaner-active_record", "~> 2.2"
  gem "launchy", "~> 3.1"
  gem "rack-test", "~> 2.2"
  gem "rspec", "~> 3.13"
end

group :tools do
  gem "amazing_print", "~> 1.7"
  gem "debug", "~> 1.10"
  gem "irb-kit", "~> 1.1"
  gem "repl_type_completor", "~> 0.1"
end

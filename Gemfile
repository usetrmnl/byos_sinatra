# frozen_string_literal: true

ruby file: ".ruby-version"

source 'https://rubygems.org'

# database, ORM, server
gem 'activerecord'
gem 'dotenv', groups: %i[development test]
gem 'forme'
gem 'json'
gem 'pry'
gem 'puma'
gem 'rackup'
gem 'rake'
gem 'sinatra-activerecord'

# browser automation
gem 'ferrum', git: 'https://github.com/rubycdp/ferrum.git', ref: '7cc1a63351232b10f9ce191104efe6e9c72acca2'
gem 'puppeteer-ruby', '~> 0.45.6'

# image processing
gem 'mini_magick', '~> 4.12.0'

# db
gem 'sqlite3'

group :development, :test do
  gem 'database_cleaner-active_record'
  gem 'debug'
  gem 'nokogiri'
  gem 'rack-test'
  gem 'rspec'
end

group :test do
  gem 'sqlite3'
end

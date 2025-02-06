source 'https://rubygems.org'

# database, ORM, server
gem 'activerecord'
gem 'json'
gem 'rake'
gem 'sinatra-activerecord'
gem 'puma'
gem 'rackup'
gem 'forme'
gem 'pry'
gem 'dotenv', groups: [:development, :test]

# browser automation
gem 'ferrum', git: 'https://github.com/rubycdp/ferrum.git', ref: '7cc1a63351232b10f9ce191104efe6e9c72acca2'
gem 'puppeteer-ruby', '~> 0.45.6'

# image processing
gem 'mini_magick', '~> 4.12.0'

#db
gem 'sqlite3'

group :development, :test do
  gem 'debug'
  gem 'nokogiri'
  gem "rspec"
  gem "rack-test"
  gem "database_cleaner-active_record"
end

group :test do
  gem 'sqlite3'
end

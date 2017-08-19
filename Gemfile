source 'https://rubygems.org'

# gem 'puma'
gem "rake"
# gem "tamarama", path: "../tamarama"
gem "tamarama", ">= 0.1.0", "< 0.2.0"
gem 'sinatra'
gem 'pg'
gem "reform"#, path: "../reform"
gem "trailblazer", ">= 2.0.7", "< 2.1.0"
# gem "trailblazer", path: "../trailblazer"
gem "trailblazer-loader", ">= 0.1.2" #path: "../trailblazer-loader"
gem "trailblazer-cells"
gem "sequel"
gem "dry-validation"
gem "cells-erb"
gem "formular", github: "trailblazer/formular"
gem "sprockets"
gem "money"

# Because of how env is loaded - this needs to be in all env
gem "dotenv"

group :development, :test do
  gem "rack-test"
  # gem "match_json"
  gem 'database_cleaner'

  gem "minitest"
  gem "minitest-line"

  # gem "trailblazer-test", path: "../trailblazer-test"
end

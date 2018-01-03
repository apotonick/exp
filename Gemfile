source 'https://rubygems.org'

# gem 'puma'
gem "rake"
# gem "tamarama", path: "../tamarama"
gem "tamarama", ">= 0.1.0", "< 0.2.0"
gem 'sinatra'
gem 'pg'
gem "reform"#, path: "../reform"
gem "trailblazer", ">= 2.1.0.beta1"#, "< 2.1.0"
# gem "trailblazer", path: "../trailblazer"
gem "trailblazer-loader", ">= 0.1.2" #path: "../trailblazer-loader"
gem "trailblazer-cells"
gem "sequel", "4.48.0" # TODO: upgrade.
gem "dry-validation"
gem "cells-erb"
gem "formular", github: "trailblazer/formular"
gem "sprockets"
gem "money"

# gem "trailblazer-endpoint", path: "../endpoint"

# Because of how env is loaded - this needs to be in all env
gem "dotenv"

gem "rubyzip"

group :development, :test do
  gem "rack-test"
  # gem "match_json"
  gem 'database_cleaner'

  gem "minitest"
  gem "minitest-line"

  gem "trailblazer-test", github: "trailblazer/trailblazer-test"
  # gem "trailblazer-test", path: "../trailblazer-test"
end

gem "capistrano", "3.8.2"
gem "capistrano-rbenv"
gem "capistrano-bundler"
gem "capistrano-passenger"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "stack/env"
require "stack/db"

DB.connect

require "trailblazer/operation"
# require "reform/form/active_model/validations"

# TODO: initializers/01_reform.rb
require "reform/form/dry"
require "reform/form/coercion"
require "disposable/twin/property/hash"
# 02_cells.rb
Trailblazer::Cell.send :include, Cell::Erb

# 03_money.rb
I18n.config.available_locales = :en
Money.add_rate("EUR", "SGD", 1.55) # Not a fan of this API.
Money.add_rate("AUD", "SGD", 1.06) # Not a fan of this API.

Reform::Form.class_eval do
  include Reform::Form::Dry
end

module Exp
end

require_relative "concepts/exp/step/created_at" # FIXME.

Trailblazer::Loader.new.(debug: false, concepts_root: "./concepts/") { |file|
  puts file
  require_relative(file) }

# In a Tamarama stack, you don't need app/concepts/ but only concepts/
Trailblazer::Cell.view_paths = ["concepts"]
# use Bootstrap 3
Formular::Helper.builder(:bootstrap3)

module Exp
  class Application < Sinatra::Base
    get "/expenses/new" do
      Expense::Endpoint::New.( params: params )
    end

    post "/expenses" do
      Expense::Endpoint.create( params: params, sinatra: self )
    end

    post "/expenses/upload" do
      Expense::Endpoint.upload( params: params, sinatra: self )
    end

    post "/claims" do
      Expense::Endpoint.claim( params: params, sinatra: self )
    end

    get "/claims/:id" do
      Claim::Endpoint.show( params: params, sinatra: self )
    end

    # Get assets going.
    # the appends tell sprockets where files *could* be, no types, nothing.
    set :environment, Sprockets::Environment.new
    environment.append_path "assets/css"
    environment.append_path "assets/js"
    environment.append_path "assets"

    get "/assets/*" do
      env["PATH_INFO"].sub!("/assets", "")
      settings.environment.(env)
    end

    # set :public_folder, "assets/__uploads"
    get "/files/:path" do
      send_file File.join("__uploads", params[:path])
    end
  end
end

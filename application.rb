Encoding.default_external = 'UTF-8' # FIXME: needed for deployed app.

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "tamarama/env"
require "tamarama/db/sequel"
require "tamarama/db/sequel/database_validator"

db = Tamarama::DB::Sequel.()
Tamarama::DB::Sequel::DatabaseValidator.(db)


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
Money.add_rate("TWD", "SGD", 0.045) # Not a fan of this API.
Money.add_rate("USD", "SGD", 1.38) # Not a fan of this API.
Money.add_rate("GBP", "SGD", 1.78) # Not a fan of this API.
Money.add_rate("RON", "SGD", 0.34) # Not a fan of this API.
Money.add_rate("HKD", "SGD", 0.18) # Not a fan of this API.
Money.add_rate("RUB", "SGD", 0.028) # Not a fan of this API.
Money.add_rate("UAH", "SGD", 0.058) # Not a fan of this API.
Money.add_rate("IDR", "SGD", 0.00016) # Not a fan of this API.
Money.add_rate("CAD", "SGD", 1.05) # Not a fan of this API.

Reform::Form.class_eval do
  include Reform::Form::Dry
end

module Exp
end

require_relative "concepts/exp/step/timestamps" # FIXME.

# FIXME: this will be introduced in loader-1.0.
# TODO: allow particular orders, e.g. expense, claim
SortConceptsAlphabetically = ->(input, *) { input.sort }

Trailblazer::Loader.new.
instance_exec do
  def default_circuit
    super.tap do |pipe|
      pipe.insert(pipe.index(Trailblazer::Loader::SortByLevel), SortConceptsAlphabetically)
    end
  end
  self
end.
(debug: false, concepts_root: "./concepts/") { |file|
  puts file
  require_relative(file) }

# In a Tamarama stack, you don't need app/concepts/ but only concepts/
Trailblazer::Cell.view_paths = ["concepts"]
# use Bootstrap 3
Formular::Helper.builder(:bootstrap3)

module Exp
  class Application < Sinatra::Base
    get "/expenses/new" do
      ::Endpoint::HTML.(Expense::Create::Present, params, Expense::Cell::New, :new)
    end

    post "/expenses" do
      ::Endpoint::HTML.(Expense::Create, params, Expense::Cell::New, :create) { |result| return redirect("/expenses/new") }
    end

    post "/expenses/upload" do
      ::Endpoint::HTML.( Expense::Upload, params, nil, nil ) do |result|
        # TODO: use representer, etc.
        JSON.dump( { files: [{ path: result["files"][0].path }] } )
      end
    end

    get "/expenses/edit/:id" do
      ::Endpoint::HTML.(Expense::Update::Present, params, Expense::Cell::Edit, :edit)
    end
    post "/expenses/:id" do
      ::Endpoint::HTML.(Expense::Update, params, Expense::Cell::Edit, :update) { |result| return redirect("/expenses/new") }
    end


    post "/claims" do
      Expense::Endpoint.claim( params: params, sinatra: self )
    end

    get "/claims/:id" do
      Claim::Endpoint.show( params: params, sinatra: self )
    end

    get "/claims/:id/rezip" do
      Claim::Endpoint.rezip( params: params, sinatra: self )
    end

    # FIXME: security?
    get "/debug/:id" do
      # return Expense::Row.last.inspect
      Expense::Update.( params: {id: 377, invoice_date: "27/12/2017"} )
      CGI::escape_html Expense::Row[ params[:id] ].inspect
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
      send_file File.join("uploads", params[:path])
    end

    get "/paypal" do
      Expense::File.( params: { expenses: [ 346, 347, 348 ] }, archive_dir: "./downloads", upload_dir: "./uploads", type: "sale-paypal", serial_number: 1, identifier: "2017-sale-paypal-1" )
    end
    get "/purchases" do
      Expense::File.( params: { expenses: [ 364, 365, 366, 367, 368 ] }, archive_dir: "./downloads", upload_dir: "./uploads", type: "purchase-ocbc", serial_number: 1, identifier: "2017-purchase-ocbc-1" )
    end
  end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "stack/env"
require "stack/db"

require "trailblazer/operation"
# require "reform/form/active_model/validations"
# require "reform/form/coercion"

Reform::Form.class_eval do
  require "reform/form/dry"
  include Reform::Form::Dry

  require "disposable/twin/property/hash"
  # include Disposable::Twin::Property::Hash # FIXME: not inherited!
end

#Dir['./models/v1/*.rb'].each { |file| require file }

Trailblazer::Loader.new.(debug: false, concepts_root: "./concepts/") { |file|
  puts file
  require_relative(file) }

# In a Tamarama stack, you don't need app/concepts/ but only concepts/
Trailblazer::Cell.view_paths = ["concepts"]
# use Bootstrap 4
Formular::Helper.builder(:bootstrap4)

module Exp
  class Application < Sinatra::Base
    get "/expenses/new" do
      Expense::Endpoint::New.( params: params )
    end
  end
end



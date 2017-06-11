
require "reform/form/coercion"
module Types
  include Dry::Types.module
end

module Expense::Form
  def self.currencies
    Money::Currency.table.values.collect { |currency| [ currency[:iso_code], currency[:iso_code] ] }
  end

  class Create < Reform::Form
    # feature Reform::Form::Coercion
    include Disposable::Twin::Property::Hash

    property :content, field: :hash do
      property :source # e.g. "Starbucks Taiwan"
      property :description
      property :unit_price
      property :qty, default: 1
      property :currency
      property :paid_at
    end

    unnest :description, from: :content
    unnest :source, from: :content
    unnest :unit_price, from: :content
    unnest :currency, from: :content

    def currencies
      Expense::Form.currencies
    end

    def currency
      super || "EUR"
    end
  end
end

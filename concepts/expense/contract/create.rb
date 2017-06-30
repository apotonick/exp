require "reform/form/coercion"
module Types
  include Dry::Types.module
end

module Expense::Form
  def self.currencies
    Money::Currency.table.values.collect { |currency| [ currency[:iso_code], currency[:iso_code] ] }
  end

  # Note how the form doesn't know anything about the nested hash fields, etc.
  # It simply relies on a flat property list, which is provided by the twin.
  class Create < Reform::Form
    property :source # e.g. "Starbucks Taiwan"
    property :description
    property :unit_price
    property :qty, default: 1
    property :currency
    property :paid_at
    property :file_path
    property :invoice_number

    def currencies
      Expense::Form.currencies
    end

    def currency
      super || "EUR"
    end
  end
end

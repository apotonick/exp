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
    property :file_path
    property :invoice_number
    property :invoice_date

    validation do
      required(:source).filled
      required(:unit_price).filled#(format?: /^([\d+\.{1},.]||[\d+,{1}\..]||\d+)$/)
      required(:currency).value(included_in?: Expense::Form.currencies.collect { |cfg| cfg.first })
      required(:invoice_number).filled
      # required(:invoice_date).maybe(format?: "\d\d/\d\d/\d\d\d\d")
    end

    def currencies
      Expense::Form.currencies
    end

    def currency
      super || "EUR"
    end

    # The coercer sits on the contract as this is a pure UI-targeted feature. The underlying data twin
    # always expects a proper value.
    def unit_price=(v)
      # TODO: use digits parser gem here.
      formatted = if v =~ /,\d{1,2}$/    # 1,23 or 1.004,56
        v.sub(".", "").sub(",", ".")
      # elsif v =~ /\.\d{1,2}/ # 1.23 or 1,004.56
      else
        v.sub(",", "")
      end

      super(formatted)
    end
  end
end

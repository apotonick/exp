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
    # include Reform::Form::Coercion
    property :source # e.g. "Starbucks Taiwan"
    property :description
    property :unit_price#, type: Types::Form::Float
    property :qty, default: 1
    property :currency
    property :file_path
    property :invoice_number
    property :invoice_date
    property :notes

    property :txn_direction, parse: false # oh man, this API sucks.
    property :txn_type
    property :txn_account

    property :folder_id

    validation do
      required(:source).filled
      required(:unit_price) { float? } #(format?: /^([\d+\.{1},.]||[\d+,{1}\..]||\d+)$/)
      required(:currency).value(included_in?: Expense::Form.currencies.collect { |cfg| cfg.first })
      required(:invoice_number).filled
      # required(:invoice_date).maybe(format?: "\d\d/\d\d/\d\d\d\d")

      # required(:txn_direction).value( included_in?: %w(incoming outgoing) )
      required(:txn_type).value( included_in?: %w(sale expense purchase receipt) )
      required(:txn_account).value( included_in?: %w(bank paypal stripe) ) # DISCUSS: configurable?

      required(:folder_id).maybe { int? }
    end

    def currencies
      Expense::Form.currencies
    end

    def currency
      super || "EUR"
    end

    # The coercer sits on the contract as this is a pure UI-targeted feature. The underlying data twin
    # always expects a proper value.

    # coercion/deserialization should only happen when v.not_nil?
    # property :unit_price
    #   it must always call the setter since we want it to be nilable, the coercer should be called from the deserializer or at least have the same semantics.
# is default also a coercion/deserialization? value=(nil=>"default value")
    def unit_price=(v)
      # @original_input ||= {}
      # @original_input[:unit_price] = v

      #- nilify, should happen in representer
      v = nil if v == ""
      #- if nil?
      return super(v) if v.nil? # DISCUSS: where should this happen?, the nilify

      #- pre-validation: convert from 3,600.60 to 3600.60

      # TODO: use digits parser gem here.
      formatted = if v =~ /,\d{1,2}$/    # 1,23 or 1.004,56
        v.sub(".", "").sub(",", ".")
      # elsif v =~ /\.\d{1,2}/ # 1.23 or 1,004.56
      else
        v.sub(",", "")
      end
      # how to we still present the original value in the re-renderd form
      # if we aren't happy with the format, how could we prevent further validation for this and still add an error?

      #- type coercion
      float = Types::Form::Float.(formatted) # this used to happen via `type: Types::Form::Float`.

      #- test if it's decimal/dots, only?

      #- computation to target value
      super(float * 100)
    end

    # we need a submitted form and a edit form!
    def unit_price
      # this still doesn't "restore" 1.299,95 but shows 1299.95, which could confuse the user
      return if super.nil?
      # return super unless super.is_a?(Integer) # FIXME: this is for faulty input after validation and must not be here!!!!! e.g. unit_price: 2341234234asfdsadf
      super / 100
    end

    def invoice_date=(v)
      return super(v) if v.nil? # DISCUSS: where should this happen?, the nilify

      now_year = Time.now.strftime("%Y")

      # allow dates like 24/12 or 24/12/17 because it's super handy.
      formatted = if match = v.match(/\d{1,2}[^\d]+\d{1,2}[^\d]+(\d{2})$/)
        v.sub(/#{match[1]}$/, "20#{match[1]}") # assuming this app won't be run in 21xx.
      elsif v.match(/\d{1,2}[^\d]+\d{1,2}$/)
        "#{v}/#{now_year}"
      else
        v
      end

      date = Types::Form::DateTime.(formatted)

      super(date)#.tap do |date|
      #   puts "@@@@@ #{date.inspect}"
      # end
    end

        # the problem is: present the date as something completely different to what's on the model.
    #   then, don't update that value if it hasn't changed. that means the setter that converts hasn't been run
    def invoice_date
      return if super.nil? || super == ""
      return super unless super.is_a?(DateTime)
      super.strftime("%d/%b/%y")
    end
  end
end

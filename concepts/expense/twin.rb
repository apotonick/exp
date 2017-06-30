module Expense::Twin
  # The twin's job is mapping the database object to a domain object, e.g. by
  # hiding the hash field `content`.
  class Create < Disposable::Twin
    feature Disposable::Twin::Coercion
    include Disposable::Twin::Property::Hash

    property :content, field: :hash do
      property :source # e.g. "Starbucks Taiwan"
      property :description
      property :unit_price, type: Types::Form::Float
      property :qty, default: 1
      property :currency
      property :paid_at
      property :file_path
      property :invoice_number # arbitrary ID, like booking number.
      property :created_at # FIXME, only writeable at Create
    end

    property :id, writeable: false # FIXME: only for `row`. # fixme: gives evil constraint error when not readonly.

    # TODO: `unnest :content` for all
    unnest :description, from: :content
    unnest :source, from: :content
    unnest :unit_price, from: :content
    unnest :currency, from: :content
    unnest :qty, from: :content
    unnest :paid_at, from: :content
    unnest :file_path, from: :content
    unnest :invoice_number, from: :content
    unnest :created_at, from: :content

    # FIXME: only needed for Create/Update
    # This sits here since we want the twin.unit_price = 1.2 everywhere.
    # THIS IS WHY super sucks and circuits rule:
    module UnitPrice
      def unit_price=(v)
        v= super(v)
        super(v * 100)
      end
    end
    include UnitPrice

    # FIXME: only needed for Index/Show
    def effective_amount
      converted = effective_money
      "#{converted.currency} #{converted.format}"
    end

    # FIXME: only needed for Show
    def amount
      price = Money.new(unit_price, currency)
      "#{price.currency} #{price.format}"
    end

    # DISCUSS: only in cell?
    def description
      [ source, super ].compact.join(" / ")
    end

    def effective_money # TODO: only for Index/Show/Claim::Create
      Money.new(unit_price * content.qty, currency).exchange_to("SGD")
    end

    # FIXME: only needed for Create/Update
    include Disposable::Twin::Sync
    include Disposable::Twin::Save
  end
end

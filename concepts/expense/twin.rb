module Expense::Twin
  # The twin's job is mapping the database object to a domain object, e.g. by
  # hiding the hash field `content`.
  class Domain < Disposable::Twin # TODO: this should be Read-only, no setters
    feature Disposable::Twin::Coercion
    include Disposable::Twin::Property::Hash

    property :content, field: :hash do
      property :source # e.g. "Starbucks Taiwan"
      property :description
      property :unit_price#, type: Types::Form::Float
      property :qty, default: 1
      property :currency
      property :file_path
      property :invoice_number # arbitrary ID, like booking number.
      property :invoice_date#, type: Types::Form::DateTime # this should only coerce at read. but this should break when set with non-DateTime.
      property :created_at # FIXME, only writeable at Create
      property :updated_at # FIXME, only writeable at Update
    end

    property :id, writeable: false # FIXME: only for `row`. # fixme: gives evil constraint error when not readonly.

    # TODO: `unnest :content` for all
    unnest :description, from: :content
    unnest :source, from: :content
    unnest :unit_price, from: :content
    unnest :currency, from: :content
    unnest :qty, from: :content
    unnest :file_path, from: :content
    unnest :invoice_number, from: :content
    unnest :invoice_date,   from: :content
    unnest :created_at, from: :content
    unnest :updated_at, from: :content
  end

  class Create < Disposable::Twin
        feature Disposable::Twin::Coercion
    include Disposable::Twin::Property::Hash

    property :content, field: :hash do
      property :source # e.g. "Starbucks Taiwan"
      property :description
      property :unit_price, type: Types::Form::Float
      property :qty, default: 1
      property :currency
      property :file_path
      property :invoice_number # arbitrary ID, like booking number.
      property :invoice_date, type: Types::Form::DateTime
      property :notes
      property :created_at # FIXME, only writeable at Create
      property :updated_at # FIXME, only writeable at Update

      property :txn_direction
      property :txn_type
      property :txn_account
    end

    property :folder_id
    property :index, virtual: true # FIXME: only in rendering!

    property :id, writeable: false # FIXME: only for `row`. # fixme: gives evil constraint error when not readonly.

    # TODO: `unnest :content` for all
    unnest :description, from: :content
    unnest :source, from: :content
    unnest :unit_price, from: :content
    unnest :currency, from: :content
    unnest :qty, from: :content
    unnest :file_path, from: :content
    unnest :invoice_number, from: :content
    unnest :invoice_date,   from: :content
    unnest :notes,   from: :content
    unnest :created_at, from: :content
    unnest :updated_at, from: :content

    unnest :txn_direction, from: :content
    unnest :txn_type, from: :content
    unnest :txn_account, from: :content

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

    def effective_money # TODO: only for Index/Show/Claim::Create
      Money.new(unit_price * content.qty, currency).exchange_to("SGD")
    end

    # FIXME: only needed for Create/Update
    include Disposable::Twin::Sync
    include Disposable::Twin::Save
  end
end

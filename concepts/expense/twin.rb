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
    end

    unnest :description, from: :content
    unnest :source, from: :content
    unnest :unit_price, from: :content
    unnest :currency, from: :content
    unnest :qty, from: :content
    unnest :paid_at, from: :content

    # FIXME: only needed for Index/Show
    def effective_amount
      unit_price * content.qty * 234.2
    end

    # FIXME: only needed for Create/Update
    include Disposable::Twin::Sync
    include Disposable::Twin::Save
  end
end

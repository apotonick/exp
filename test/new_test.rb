require "test_helper"

class NewTest < Minitest::Spec
  class Create < Disposable::Twin
    property :content, default: {} do
      property :source # e.g. "Starbucks Taiwan"
      property :description
      property :unit_price, type: Types::Form::Float
      property :qty#, default: 1
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

      collection :tax do
        property :amount
        property :percent
      end
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

    unnest :tax, from: :content

  end

  it do
    twin = Create.new(OpenStruct.new(content: OpenStruct.new(tax: []))) # build an empty data structure. No taxItem object, yet.
    # puts twin.tax.inspect


    twin = Disposable::Read.from_h(Create, Expense::Row.new)
    pp twin
    puts twin.tax.class
    raise

    # in a populator (as a parsing example), mutate the twin according to the incoming doc
    twin.tax.insert 0, OpenStruct.new(amount: 100, percent: 19)
    twin.folder_id = 1

    # validate/transform => here, the typing happens

    # pp twin.tax[0].amount

    # generate Changeset for ROM
    pp twin
    # pp twin.to_nested_hash

    hash = Disposable::Read.to_h(twin)
    hash.must_equal(
      {:content=>
        {:source=>nil,
         :description=>nil,
         :unit_price=>nil,
         :qty=>nil,
         :currency=>nil,
         :file_path=>nil,
         :invoice_number=>nil,
         :invoice_date=>nil,
         :notes=>nil,
         :created_at=>nil,
         :updated_at=>nil,
         :txn_direction=>nil,
         :txn_type=>nil,
         :txn_account=>nil,
         :tax=>[{:amount=>100, :percent=>19}]},
       :folder_id=>1,
       :id=>nil}
    )

    row = Expense::Row.create(hash)
    pp row

    twin = Create.new(row)
  end
end

require "disposable_extensions"

require_relative "../expense/_expense.rb"
require_relative "../expense/twin.rb"

module Claim
  # Represents the domain object of a claim, that holds many claimed expenses, a receiver, a transaction
  # of the actual bank transfer to the expensing employee, etc.
  class Twin < Disposable::Twin
    include Sync
    include Save




    property   :created_at
    collection :expenses, twin: Expense::Twin::Create, writeable: false
    property   :id, writeable: false
    # property :count, virtual: true

    include Disposable::Twin::Property::Hash
    # DISCUSS: should this be in some Twin::Table mapper?
    property :content, field: :hash, default: Hash.new do
      property :identifier # PV No.
      property :transaction_id
    end
    unnest :identifier,     from: :content
    unnest :transaction_id, from: :content

    property :serial_number


    def count
      expenses.count
    end

    def effective_total_money
      expenses.inject(Money.new(0, "SGD")) { |money, exp| money += exp.effective_money }
    end

    # TODO: last line must be extracted.
    def effective_total
      total = effective_total_money
      "#{total.currency} #{total.format}"
    end
  end
end

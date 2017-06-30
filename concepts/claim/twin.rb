require_relative "../expense/_expense.rb"
require_relative "../expense/twin.rb"

module Claim
  # Represents the domain object of a claim, that holds many claimed expenses, a receiver, a transaction
  # of the actual bank transfer to the expensing employee, etc.
  class Twin < Disposable::Twin
    collection :expenses, twin: Expense::Twin::Create
    # property :count, virtual: true

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

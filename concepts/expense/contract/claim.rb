module Expense::Form
  class Claim < Reform::Form
    collection :expenses, populator: :find_expense, writeable: false do # fixme: without block, we don't have :fragment ?!!
    end

    def find_expense(fragment:, index:, **)
      self.expenses.insert index, ::Expense::Row[fragment]
      skip! # FIXME, this is because the form is marked as nested.
    end
  end
end

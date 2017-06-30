module Expense
  class Claim < Trailblazer::Operation
    step Model( ::Claim::Row, :new )
    step Contract::Build( constant: Form::Claim )
    step Contract::Validate()
    step Exp::Step::CreatedAt
    step Contract::Persist()
    step :add_expenses!

    def add_expenses!(options, model:, **)
      options["contract.default"].expenses.each do |exp|
        model.add_expense exp.model
      end
    end
    # step ->(options, model:, **) do
    #   model.expenses
    #   model.save
    # end
  end
end


# collection :expenses
#   find
#   add_to_graph

# validate expenses
#   authorize each expense "is from user, etc, not used before, etc"

# sync to Claim
# add expenses

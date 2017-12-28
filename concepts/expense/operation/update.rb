module Expense
  class Update < Trailblazer::Operation

    class Present < Create::Present
      step Model( Row, :[] ), override: true
      # step :decorate!
      step Contract::Build( constant: Form::Update ), override: true

      # def decorate!(options, model:, **)
      #   options["model"] = Twin::Domain.new(model)
      # end
    end

    step Nested( Present )
    step Contract::Validate()
    step Expense::Create.method(:txn_direction)
    step Exp::Step::UpdatedAt
    step Contract::Persist()
    # step :id!

    def id!(options, model:, **)
      model.id = model.model.id # FIXME: how could twins do that automatically?
    end
  end
end

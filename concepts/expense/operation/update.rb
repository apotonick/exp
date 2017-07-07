module Expense
  class Update < Trailblazer::Operation

    class Present < Create::Present
      step Model( Row, :find )
      # step :decorate!
      # step Contract::Build( constant: Form::Create )

      # def decorate!(options, model:, **)
      #   options["model"] = Twin::Create.new(model)
      # end
    end

    step Nested( Present )
    step Contract::Validate()
    # step Exp::Step::CreatedAt
    step Contract::Persist()
    # step :id!

    def id!(options, model:, **)
      model.id = model.model.id # FIXME: how could twins do that automatically?
    end
  end
end

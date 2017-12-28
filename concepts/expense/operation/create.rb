module Expense
  class Create < Trailblazer::Operation
    class Present < Trailblazer::Operation
      step Model( Row, :new )
      step :decorate!
      step Contract::Build( constant: Form::Create )

      def decorate!(options, model:, **)
        options[:model] = Twin::Create.new(model)
      end
    end

    def self.txn_direction( ctx, ** )
      contract = ctx["contract.default"]
      contract.txn_direction = %w(sale).include?( contract.txn_type ) ? "incoming" : "outgoing"
    end

    step Nested( Present )
    step Contract::Validate()
    step method(:txn_direction)
    step Exp::Step::CreatedAt, name: "timestamp.created_at" # note that this is *not* a macro but simply a callable.
    step Contract::Persist()
    step :id!

    def id!(options, model:, **)
      model.id = model.model.id # FIXME: how could twins do that automatically?
    end

  end
end

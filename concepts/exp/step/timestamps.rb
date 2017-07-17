module Exp
  CurrentTime = -> { DateTime.now } # the application-global "now" implementation. could also be provided via our dry-container.

  module Step
    # DISCUSS: what is easier to understand, the class with ::call or the lambda (UpdatedAt)?
    #   please comment!

    class CreatedAt
      extend Uber::Callable # TODO: remove in 2.1.

      def self.call(options, model:, time: Exp::CurrentTime, **)
        model.created_at = time.()
      end
    end

    UpdatedAt = ->(options, model:, time: Exp::CurrentTime, **) do
      model.updated_at = time.()
    end
  end
end

module Exp
  CurrentTime = -> { DateTime.now } # this could also be provided via our dry-container.

  module Step
    class CreatedAt
      extend Uber::Callable # TODO: remove in 2.1.

      def self.call(options, model:, time: Exp::CurrentTime, **)
        model.created_at = time.()
      end
    end
  end
end

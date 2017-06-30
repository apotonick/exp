module Exp::Step
  class CreatedAt
    extend Uber::Callable

    def self.call(options, model:, **)
      model.created_at = DateTime.now
    end
  end
end

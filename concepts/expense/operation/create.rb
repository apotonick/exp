module Expense
  class Create < Trailblazer::Operation
    class Present < Trailblazer::Operation
      step Model( Row, :new )
      step Contract::Build( constant: Form::Create )
    end

    step Nested( Present )
  end
end

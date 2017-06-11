module Expense::Cell
  class Index < Trailblazer::Cell
    include Cell::Erb

    def model
      Expense::Row.all.reverse.collect { |row| Expense::Twin::Create.new(row) }
    end

    class Row < Trailblazer::Cell
      extend ViewName::Flat
    end
  end
end

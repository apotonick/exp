module Expense::Cell
  class New < Trailblazer::Cell
    include Cell::Erb

    def post_url
      "/expenses"
    end

    def heading
      "Create expense"
    end
  end
end

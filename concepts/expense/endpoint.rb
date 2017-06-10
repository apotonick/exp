module Expense::Endpoint
  class New
    def self.call(params:, **)
      Expense::Cell::New.().()
    end
  end
end

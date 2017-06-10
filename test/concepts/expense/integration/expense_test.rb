require "test_helper"

class ExpenseTest < Minitest::Spec
  it do
    html = Expense::Endpoint::New.( params: {} )
    html.must_equal %{}
  end
end

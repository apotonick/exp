require "test_helper"

class ExpenseOperationTest < Minitest::Spec
  it do
    params_valid = { source: "Biosk", description: "Beer", unit_price: "1.2", currency: "EUR" }
    result = Expense::Create.( params_valid )

    model = result["model"]

    model.source.must_equal "Biosk"
    model.description.must_equal "Beer"
    model.unit_price.must_equal 1.2 # coerced!
    model.currency.must_equal "EUR"
  end
end

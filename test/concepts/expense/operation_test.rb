require "test_helper"

class ExpenseOperationTest < Minitest::Spec
  it do
    params_valid = { source: "Biosk", description: "Beer", unit_price: "1.2", currency: "EUR" }
    result = Expense::Create.( params_valid )

    model = result["model"]

    model.source.must_equal "Biosk"
    model.description.must_equal "Biosk / Beer"
    model.unit_price.must_equal 120 # coerced and centified!
    model.currency.must_equal "EUR"

    # twin test
    model.amount.must_equal %{EUR €1,20}
  end
end

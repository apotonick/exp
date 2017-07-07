require "test_helper"

class ExpenseOperationTest < Minitest::Spec
  let(:params_valid) do
    { source: "Biosk", description: "Beer", unit_price: "1.2", currency: "EUR",
      invoice_number: "1234567890",
      invoice_date:   "24/12/2017",
    }
  end

  it "is successful" do
    result = Expense::Create.( params_valid )

    result.success?.must_equal true

    result["model"].must_expose( params_valid,
      unit_price:   120,
      description:  "Biosk / Beer",
      invoice_date: Date.parse("24/12/2017"),
      amount:       %{EUR €1,20} # twin test
    )
  end

  it "works without invoice_date" do
    result = Expense::Create.( params_valid.merge(invoice_date: nil) ) # TODO: run(Op, params_valid, nil: [:invoice_date])

    result.success?.must_equal true

    result["model"].must_expose( params_valid,
      unit_price:   120,
      description:  "Biosk / Beer",
      invoice_date: nil,
      amount:       %{EUR €1,20} # twin test
    )
  end

  # TODO: date format validation, since we can assume it's a Date after coercion ("typing").
  it "fails with missing invoice number, price, currency, " do
    result = Expense::Create.( params_valid.merge(invoice_number: nil, currency: nil, unit_price: nil, ) )

    result.failure?.must_equal true

    result["contract.default"].errors.messages.keys.must_equal [:unit_price, :currency, :invoice_number]

    result["model"].model.id.must_be_nil
  end

  describe "Update" do
    it "updates attributes" do
      result = Expense::Create.( params_valid )

      result = Expense::Update.( params_valid.merge( i__d: result["model"].id, unit_price: "333.31" ) )

      result.success?.must_equal true

      result["model"].must_expose( params_valid, unit_price: 333.31 )
    end
  end
end

module MiniTest::Assertions
  def assert_result_matches(result, defaults, overrides)
    tuples = defaults.merge(overrides)

    tuples.each do |k, v|
      assert( result[k] == v, %{Expected result["#{k}"] to == `#{v}`} )
    end
  end

  def assert_exposes(result, defaults, overrides)
    tuples = defaults.merge(overrides) # FIXME: merge with above!

    tuples.each do |k, v|
      actual = result.send(k)
      assert( actual == v, %{Expected result["#{k}"](#{actual}) to == `#{v}`} )
    end
  end
end
Trailblazer::Operation::Result.infect_an_assertion :assert_result_matches, :must_match, :do_not_flip
Object.infect_an_assertion :assert_exposes, :must_expose, :do_not_flip

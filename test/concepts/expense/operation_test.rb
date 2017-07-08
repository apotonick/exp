require "test_helper"


module Trailblazer::Operation::Test
  module Assertions
    def assert_passes(operation_class, params, expected_attributes)
      default_params = params_valid
      default_attributes = attributes_valid # FIXME.

      result = operation_class.( default_params.merge(params) )

      result.success?.must_equal true

      result["model"].must_expose( default_params,
        default_attributes.merge(expected_attributes)
      )
    end
  end
end

class ExpenseOperationTest < Minitest::Spec
  let(:params_valid) do
    { source: "Biosk", description: "Beer", unit_price: "1.2", currency: "EUR",
      invoice_number: "1234567890",
      invoice_date:   "24/12/2017",
    }
  end

  # attributes on the resulting twin, possibly overriding incoming param values.
  let(:attributes_valid) do
    {
      description: "Biosk / Beer",
      unit_price: 120,
      invoice_date: Date.parse("24/12/2017"),
    }
  end

  it "is successful" do
    result = Expense::Create.( params_valid )

    result.success?.must_equal true

    result["model"].must_expose( params_valid,
      attributes_valid.merge({
        amount:       %{EUR €1,20}
      }) # twin test
    )
  end

  it "works without invoice_date" do
    result = Expense::Create.( params_valid.merge(invoice_date: nil) ) # TODO: run(Op, params_valid, nil: [:invoice_date])

    result.success?.must_equal true

    result["model"].must_expose( params_valid,
      attributes_valid.merge(invoice_date: nil)
    )
  end

  describe "price trimming" do
    it { assert_passes Expense::Create, { unit_price: "  22.1 " }, { unit_price: 2210 } }
  end

  describe "EU/US price formatting" do
    it { assert_passes Expense::Create, { unit_price: "29" }, { unit_price: 2900 } }
    # it { assert_passes Expense::Create, { unit_price: ".29" }, { unit_price: 29 } }
    it { assert_passes Expense::Create, { unit_price: "29,95" }, { unit_price: 2995.0 } }
    it { assert_passes Expense::Create, { unit_price: "29.95" }, { unit_price: 2995.0 } }
    it { assert_passes Expense::Create, { unit_price: "2.999,95" }, { unit_price: 299995.0 } }
    it { assert_passes Expense::Create, { unit_price: "2,999.95" }, { unit_price: 299995.0 } }
    # it { assert_fails  Expense::Create, { unit_price: "2,999.95" }, { unit_price: ["wrong"] } }
  end

  # matcher params: params_valid, attributes: attributes_valid, model_path: "model", success: true

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

      result = Expense::Update.( params_valid.merge( id: result["model"].id, unit_price: "333.31" ) )

      result.success?.must_equal true

      result["model"].must_expose( params_valid, attributes_valid.merge(
        unit_price: 33331.0
      ) )
    end
  end

  include Trailblazer::Operation::Test::Assertions
end



module MiniTest::Assertions
  def assert_result_matches(result, defaults, overrides)
    tuples = defaults.merge(overrides)

    tuples.each do |k, v|
      assert( result[k] == v, %{Expected result["#{k.inspect}"] to == `#{v.inspect}`} )
    end
  end

  def assert_exposes(result, defaults, overrides)
    tuples = defaults.merge(overrides) # FIXME: merge with above!

    tuples.each do |k, v|
      actual = result.send(k)
      assert( actual == v, %{Expected actual result["#{k}"] `#{actual.inspect}` == `#{v.inspect}`} )
    end
  end
end
Trailblazer::Operation::Result.infect_an_assertion :assert_result_matches, :must_match, :do_not_flip
Object.infect_an_assertion :assert_exposes, :must_expose, :do_not_flip

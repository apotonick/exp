require "test_helper"


module Trailblazer::Test::Operation
  module Assertions
    def assert_passes(operation_class, params, expected_attributes, &block)
      default_params = params_valid
      default_attributes = attributes_valid # FIXME.

      result = operation_class.( default_params.merge(params) )

      assert_result_passes(result, expected_attributes, &block)
    end

    def assert_result_passes(result, expected_attributes={}, &block) # TODO: test expected_attributes default param and explicit!
      assert_equal true, result.success?

      return yield result if block_given?  # DISCUSS: result or model?

      assert_exposes( result["model"], expected_attributes )
    end
  end
end

class ExpenseOperationTest < Minitest::Spec
  let(:params_valid) do
    { source: "Biosk", description: "Beer", unit_price: "1.2", currency: "EUR",
      invoice_number: "1234567890",
      invoice_date:   "24/12/2017",
      notes: "Good stuff!"
    }
  end

  # attributes on the resulting twin, possibly overriding incoming param values.
  let(:attributes_valid) do
    {
      description: "Beer",
      unit_price: 120,
      invoice_date: Date.parse("24/12/2017"),
    }
  end

  it "is successful" do
    assert_passes Expense::Create, {}, { amount:       %{EUR €1,20} }
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

  describe "date formats and shortcuts" do
    it { assert_passes Expense::Create, { invoice_date: "24/12/2012" }, { invoice_date: Date.parse("24.12.2012") } }
    it { assert_passes Expense::Create, { invoice_date: "24.12.2012" }, { invoice_date: Date.parse("24.12.2012") } }
    it { assert_passes Expense::Create, { invoice_date: "24/12/12" }, { invoice_date: Date.parse("24.12.2012") } }
    it { assert_passes Expense::Create, { invoice_date: "24/12" }, { invoice_date: Date.parse("24.12.2017") } }
    it { assert_passes Expense::Create, { invoice_date: "24/2" }, { invoice_date: Date.parse("24.02.2017") } }
    it { assert_passes Expense::Create, { invoice_date: nil }, { invoice_date: nil } }
  end

  describe "with receipt upload" do
    it { assert_passes Expense::Create, { file_path: "" }, file_path: "" }
    it { assert_passes Expense::Create, { file_path: "/uploads/bild.png" }, file_path: "/uploads/bild.png" }
  end

  describe "created_at, updated_at" do
    # this tests both updated_at and created at
    it { assert_passes(Expense::Create, {}, updated_at: nil) { |result| assert result["model"].created_at > DateTime.now-1 } }

    # every timestamp's unique.
    it { Expense::Create.(params_valid)["model"].created_at < Expense::Create.(params_valid)["model"].created_at }
  end

  # matcher params: params_valid, attributes: attributes_valid, model_path: "model", success: true

  # TODO: date format validation, since we can assume it's a Date after coercion ("typing").
  it "fails with missing invoice number, price, currency, " do
    result = Expense::Create.( params_valid.merge(invoice_number: nil, currency: nil, unit_price: nil, ) )

    result.failure?.must_equal true

    result["contract.default"].errors.messages.keys.must_equal [:unit_price, :currency, :invoice_number]

    result["model"].model.id.must_be_nil
  end
  it do
    # Expense::Create.( { unit_price: "29a" }, { unit_price: 2900 } })
  end

  describe "Update" do
    let(:expense) { Expense::Create.( params_valid )["model"] }

    it { assert_passes Expense::Update, { id: expense.id, unit_price: "333.31" }, { unit_price: 33331.0, id: expense.id } }
    it { assert_passes Expense::Update, { id: expense.id, invoice_date: "31.3.17" }, { invoice_date: Date.parse("31.03.2017"), id: expense.id } }

    describe "created_at, updated_at" do
      it { assert_passes(Expense::Update, { id: expense.id }, created_at: expense.created_at) do |result| assert result["model"].updated_at > expense.created_at end }
    end

    # TODO: don't override/nil-out receipt
    describe "empty file_path" do
      # currently, this will simply override the old path
      it { assert_passes Expense::Update, { id: expense.id, file_path: "/something/completely/different" }, file_path: "/something/completely/different" }
    end

    # TODO: test overwriting notes, etc.
    describe "overwrite notes" do
      # DISCUSS: can we automate such tests, somehow?
      it { assert_passes Expense::Update, { id: expense.id, notes: "Great!" }, notes: "Great!" }
    end
  end

  include Trailblazer::Test::Assertions



  include Trailblazer::Test::Operation::Assertions
end

require "test_helper"

class ExpenseOperationTest < Minitest::Spec

  let(:options_pass) do
    {
      params: {
        source: "Biosk", description: "Beer", unit_price: "1.2", currency: "EUR",
        invoice_number: "1234567890",
        invoice_date:   "24/12/2017",
        notes: "Good stuff!",

        txn_type:      "expense",
        txn_account:   "bank",
      }
    }
  end

  # attributes on the resulting twin, possibly overriding incoming param values.
  let(:attrs_pass) do
    {
      description: "Beer",
      unit_price: 120,
      invoice_date: Date.parse("24/12/2017"),

      txn_direction: "outgoing",
      txn_type:      "expense",
      txn_account:   "bank",
    }
  end

  def assert_pass(operation, params, attrs_pass, &block)
    super( operation, { params: params }, attrs_pass, &block )
  end

  it "is successful" do
    assert_pass Expense::Create, {}, { amount:       %{EUR €1,20} }
  end

  describe "price trimming" do
    it { assert_pass Expense::Create, { unit_price: "  22.1 " }, { unit_price: 2210 } }
  end

  describe "EU/US price formatting" do
    it { assert_pass Expense::Create, { unit_price: "29" }, { unit_price: 2900 } }
    # it { assert_pass Expense::Create, { unit_price: ".29" }, { unit_price: 29 } }
    it { assert_pass Expense::Create, { unit_price: "29,95" }, { unit_price: 2995.0 } }
    it { assert_pass Expense::Create, { unit_price: "29.95" }, { unit_price: 2995.0 } }
    it { assert_pass Expense::Create, { unit_price: "2.999,95" }, { unit_price: 299995.0 } }
    it { assert_pass Expense::Create, { unit_price: "2,999.95" }, { unit_price: 299995.0 } }
    # it { assert_fails  Expense::Create, { unit_price: "2,999.95" }, { unit_price: ["wrong"] } }
  end

  describe "date formats and shortcuts" do
    it { assert_pass Expense::Create, { invoice_date: "24/12/2012" }, { invoice_date: Date.parse("24.12.2012") } }
    it { assert_pass Expense::Create, { invoice_date: "24.12.2012" }, { invoice_date: Date.parse("24.12.2012") } }
    it { assert_pass Expense::Create, { invoice_date: "24/12/12" }, { invoice_date: Date.parse("24.12.2012") } }
    it { assert_pass Expense::Create, { invoice_date: "24/12" }, { invoice_date: Date.parse("24.12.2017") } }
    it { assert_pass Expense::Create, { invoice_date: "24/2" }, { invoice_date: Date.parse("24.02.2017") } }
    it { assert_pass Expense::Create, { invoice_date: nil }, { invoice_date: nil } }
  end

  describe "with receipt upload" do
    it { assert_pass Expense::Create, { file_path: "" }, file_path: "" }
    it { assert_pass Expense::Create, { file_path: "/uploads/bild.png" }, file_path: "/uploads/bild.png" }
  end

  describe "created_at, updated_at" do
    # this tests both updated_at and created at
    it { assert_pass(Expense::Create, {}, updated_at: nil) { |result| assert result[:model].created_at > DateTime.now-1 } }

    # every timestamp's unique.
    it { assert_pass Expense::Create, {}, created_at: ->(actual:, **) { actual < Expense::Create.(options_pass)[:model].created_at } }
  end

  # matcher params: options_pass, attributes: attributes_valid, model_path: :model, success: true

  # TODO: date format validation, since we can assume it's a Date after coercion ("typing").
  it "fails with missing invoice number, price, currency, " do
    result = assert_fail Expense::Create, { params: { invoice_number: nil, currency: nil, unit_price: nil } }, [:unit_price, :currency, :invoice_number]

    result[:model].model.id.must_be_nil
  end

  describe "invalid input" do
    it { assert_fail Expense::Create, { params: { unit_price: "29a" } }, [:unit_price] }
  end

  describe "txn_account, txn_direction and txn_type" do
    # accept variables
    it { assert_pass( Expense::Create, { txn_type: "purchase", txn_account: "bank" }, { txn_direction: "outgoing", txn_type: "purchase", txn_account: "bank" } ) }
    it { assert_pass( Expense::Create, { txn_type: "sale",     txn_account: "bank" }, { txn_direction: "incoming", txn_type: "sale", txn_account: "bank" } ) }
    it { assert_pass( Expense::Create, { txn_type: "expense",  txn_account: "bank" }, { txn_direction: "outgoing", txn_type: "expense", txn_account: "bank" } ) }
    it { assert_pass( Expense::Create, { txn_type: "expense",  txn_account: "paypal" }, { txn_direction: "outgoing", txn_type: "expense", txn_account: "paypal" } ) }
    it { assert_pass( Expense::Create, { txn_type: "sale",     txn_account: "stripe" }, { txn_direction: "incoming", txn_type: "sale", txn_account: "stripe" } ) }

    it "fails with invalid type" do
      assert_fail Expense::Create, { params: { txn_direction: "undef", txn_type: "random", txn_account: "unknown" } }, [:txn_type, :txn_account]
    end

    it "doesn't allow overriding txn_direction manually" do
      assert_pass Expense::Create, { txn_direction: "incoming", txn_type: "expense" }, { txn_direction: "outgoing", txn_type: "expense" }
    end
  end

  describe "folder_id" do
    it { assert_pass Expense::Create, { folder_id: 1 },    { folder_id: 1 } }
    it { assert_fail Expense::Create, { params: { folder_id: "hallo" } }, [:folder_id] }
  end

  describe "Update" do
    let(:expense) { Expense::Create.( options_pass )[:model] }

    it { assert_pass Expense::Update, { id: expense.id, unit_price: "333.31" }, { unit_price: 33331.0, id: expense.id } }
    it { assert_pass Expense::Update, { id: expense.id, invoice_date: "31.3.17" }, { invoice_date: Date.parse("31.03.2017"), id: expense.id } }

    describe "created_at, updated_at" do
      it { assert_pass(Expense::Update, { id: expense.id }, created_at: expense.created_at) do |result| assert result[:model].updated_at > expense.created_at end }
    end

    # TODO: don't override/nil-out receipt
    describe "empty file_path" do
      # currently, this will simply override the old path
      it { assert_pass Expense::Update, { id: expense.id, file_path: "/something/completely/different" }, file_path: "/something/completely/different" }
    end

    # TODO: test overwriting notes, etc.
    describe "overwrite notes" do
      # DISCUSS: can we automate such tests, somehow?
      it { assert_pass Expense::Update, { id: expense.id, notes: "Great!" }, notes: "Great!" }
    end

    describe "set txn_* on legacy model" do
      it "sets txn_type if it wasn't set before" do
        expense = Expense::Create.( options_pass )[:model]
        expense = Expense::Row[ expense.id ]
        expense.content["txn_type"] = nil
        expense.content["txn_direction"] = nil
        expense.save

        assert_pass( Expense::Update, { id: expense.id, txn_type: "purchase", txn_account: "bank", }, { txn_direction: "outgoing", txn_type: "purchase", txn_account: "bank" } )
      end
    end
  end
end

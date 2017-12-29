require "test_helper"

class ClaimTwinTest < Minitest::Spec
  before { Claim::Row.truncate }

  it do
    expense_1 = factory( Expense::Create, params: { invoice_number: "I1", source: "Biosk", unit_price: "10", currency: "AUD", folder_id: 1, txn_type: "expense", txn_account: "bank"} )[:model]
    expense_2 = factory( Expense::Create, params: { invoice_number: "I2", source: "At",    unit_price: "11",  currency: "AUD", folder_id: 1, txn_type: "expense", txn_account: "bank"} )[:model]

    claim     = Expense::Claim.( params: { expenses: [ expense_1.id, expense_2.id ] } )[:model]

    # this twin goes into Cell::Voucher.
    twin      = Claim::Twin.new(claim)

    twin.count.must_equal 2
    twin.expenses[0].effective_money.format.must_equal "$10.60"
    twin.expenses[1].effective_money.format.must_equal "$11.66"

    twin.expenses[0].effective_amount.must_equal "SGD $10.60"
    twin.expenses[1].effective_amount.must_equal "SGD $11.66"

    twin.expenses[0].index.must_equal "001"
    twin.expenses[1].index.must_equal "002"

    twin.effective_total_money.format.must_equal "$22.26"
    twin.effective_total.must_equal "SGD $22.26"

    assert twin.created_at > Time.now-10 # TODO: nicer date tests.
    assert twin.created_at <= Time.now

    assert twin.serial_number.to_i > 0
    twin.identifier.must_equal "PV17-N-00#{twin.serial_number}-TT"
  end
end

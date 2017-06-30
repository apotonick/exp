require "test_helper"

class ClaimTwinTest < Minitest::Spec
  it do
    expense_1 = Expense::Create.( unit_price: 10, currency: "AUD", identifier: "001" )["model"]
    expense_2 = Expense::Create.( unit_price: 11, currency: "EUR", identifier: "002" )["model"]

    claim     = Expense::Claim.( expenses: [ expense_1.id, expense_2.id ] )["model"]

    # this twin goes into Cell::Voucher.
    twin      = Claim::Twin.new(claim)

    twin.count.must_equal 2
    twin.expenses[0].effective_money.format.must_equal "$10.60"
    twin.expenses[1].effective_money.format.must_equal "$17.05"

    twin.expenses[0].effective_amount.must_equal "SGD $10.60"
    twin.expenses[1].effective_amount.must_equal "SGD $17.05"

    twin.effective_total_money.format.must_equal "$27.65"
    twin.effective_total.must_equal "SGD $27.65"

    assert twin.created_at > Time.now-10 # TODO: nicer date tests.
    assert twin.created_at <= Time.now

    assert twin.serial_number.to_i > 0
    twin.identifier.must_equal "PV17-N-00#{twin.serial_number}-TT"
  end
end

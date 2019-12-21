module Expense
  class Index < Trailblazer::Operation
    step :find

    def find(ctx, params:, **)
      entities = Expense::Row.where("payment_voucher_id IS NULL")
        .collect { |row| Expense::Twin::Create.new(row) }
        .sort { |a,b| b.invoice_date <=> a.invoice_date }
        .find_all { |twin| twin.txn_type == "expense" }
        # where(invoice_date: DateTime.parse("01-01-2018")..DateTime.parse("31-12-2018")).
        # .find_all { |twin| twin.invoice_date >= DateTime.parse("01-01-2018") && twin.invoice_date <= DateTime.parse("31-12-2018") }

      ctx[:entities] = entities
    end
  end
end

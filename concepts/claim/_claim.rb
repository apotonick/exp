module Claim
  class Row < Sequel::Model(:payment_vouchers)
    one_to_many :expenses, class: "Expense::Row", key: :payment_voucher_id
  end
end

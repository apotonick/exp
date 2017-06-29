module Claim
  class Row < Sequel::Model(:claims)
    one_to_many :expenses, class: "Expense::Row", key: :claim_id
  end
end

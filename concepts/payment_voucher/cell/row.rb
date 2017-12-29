module PaymentVoucher
  module Cell
    class Row < Trailblazer::Cell
      property :description
      property :amount
      property :qty
      property :invoice_number
      property :created_at
      property :index

      def total
        model.effective_amount
      end
    end
  end
end

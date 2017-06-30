module PaymentVoucher
  module Cell
    class Row < Trailblazer::Cell
      # TODO: all this must come from Claim::Twin::Expenses
      def index
        options[:index]
      end

      property :description
      property :amount
      property :qty
      property :invoice_number
      property :created_at

      def total
        model.effective_amount
      end
    end
  end
end

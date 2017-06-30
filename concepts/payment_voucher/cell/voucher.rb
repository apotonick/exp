module PaymentVoucher
  module Cell
    class Voucher < Trailblazer::Cell
      def initialize(model, *args)
        super( Claim::Twin.new(model), *args )
      end

      # The date, formatted in this way, is only needed in an HTML view.
      def date
        model.created_at.strftime("%d-%b-%Y")
      end

      def pv
        model.identifier
      end

      def expenses
        # DISCUSS: do this further up?
        model.expenses
      end

      def total
        model.effective_total
      end
    end
  end
end

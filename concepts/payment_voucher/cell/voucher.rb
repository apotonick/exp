module PaymentVoucher
  module Cell
    class Voucher < Trailblazer::Cell
      def date

      end

      def pv

      end

      def rows
        model.expenses.collect { |exp| Expense::Twin::Create.new(exp) }
      end
    end
  end
end

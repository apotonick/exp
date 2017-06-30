module Expense::Cell
  class Index < Trailblazer::Cell
    include Cell::Erb

    def model
      # Expense::Row.all.reverse.collect { |row| Expense::Twin::Create.new(row) }
      Expense::Row.where("payment_voucher_id IS NULL").
       # order(:copies_sold).
       # limit(10).
       collect { |row| Expense::Twin::Create.new(row) }
       .reverse
    end

    # An actual row presenting an expense/receipt in a table view.
    class Row < Trailblazer::Cell
      extend ViewName::Flat

      property :file_path
      property :invoice_number

      def receipt_link
        return unless has_receipt?
        # TODO: use Sinatra/Hanami's routing helpers.
        # todo: TEST if file_path
        %{<a href="/files/#{file_path}" alt="#{file_path}"><i class="fa fa-file-o"></i> #{invoice_number}</a>}
      end

      def has_receipt?
        file_path
      end
    end
  end
end

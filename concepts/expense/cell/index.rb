module Expense::Cell
  class Index < Trailblazer::Cell
    include Cell::Erb


    def model
      Expense::Row.all.reverse.collect { |row| Expense::Twin::Create.new(row) }
    end

    # An actual row presenting an expense/receipt in a table view.
    class Row < Trailblazer::Cell
      extend ViewName::Flat

      property :file_path

      def receipt_link
        return unless file_path
        # TODO: use Sinatra/Hanami's routing helpers.
        # todo: TEST if file_path
        %{<a href="/files/#{file_path}" alt="#{file_path}"><i class="fa fa-file-o"></i> Receipt</a>}
      end
    end
  end
end

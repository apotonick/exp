require_relative "new"

module Expense::Cell
  class Edit < New
    def post_url
      "/expenses/#{model.model.id}"
    end

    def show # TODO: can we do this declaratively?
      render :new
    end

    def heading
      "Edit expense"
    end
  end
end

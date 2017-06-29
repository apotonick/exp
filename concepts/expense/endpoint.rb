module Expense::Endpoint
  class New
    def self.call(params:, **)
      result = Expense::Create::Present.()
      Expense::Cell::New.( result["contract.default"] ).(  )
    end
  end

  def self.create(params:, sinatra:, **)
    result = Expense::Create.( params )

    if result.success?
      sinatra.redirect "/expenses/new"
    else
      Expense::Cell::New.( result["contract.default"] ).(  )
    end
  end

  def self.upload(params:, sinatra:, **)
    result = Expense::Upload.( params )

    # TODO: use representer, etc.
    JSON.dump( { files: [{ path: result["files"][0].path }] } )
  end
end

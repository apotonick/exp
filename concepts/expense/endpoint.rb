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

  def self.claim(params:, sinatra:, **)
    result = Expense::Claim.( params )

    if result.success?
      sinatra.redirect "/claims/#{result["model"].id}"
    else
      "broken!"
    end
  end
end

module Claim::Endpoint
  def self.show(params:, sinatra:, **)

    return PaymentVoucher::Cell::Voucher.( Claim::Row[params[:id]] ).()
    Claim::Cell::Show.( Claim::Row[params[:id]] ).()
  end
end

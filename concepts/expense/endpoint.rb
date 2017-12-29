# require "trailblazer/endpoint"

module Endpoint
  module HTML
    def self.call(operation, options, cell, hint, &block)
      result = operation.( params: options ) # this should happen in the endpoint gem.

      if result.success? && block_given? # first pattern
        yield_block(result, &block)
      elsif result.success? && hint == :new # next matcher
        render(cell, result)
      elsif result.success? && hint == :edit # next matcher
        render(cell, result)
      elsif result.failure? && hint == :create # next matcher
        render(cell, result) # same resolve
      elsif result.failure? && hint == :update # next matcher
        render(cell, result) # same resolve
      end
    end

    # @resolve action
    def self.yield_block(result, &block)
      yield(result)
    end
    # @resolve action
    def self.render(cell, result)
      cell.( result["contract.default"], layout: Bootstrap::Cell::Layout ).()
    end
  end
end

module Expense
  module Endpoint

  def self.claim(params:, sinatra:, **)
    result = Expense::Claim.( params: params, archive_dir: "./downloads", upload_dir: "./uploads" )

    if result.success?
      sinatra.redirect "/claims/#{result[:model].id}"
    else
      "broken!"
    end
  end
end
end

module Claim::Endpoint
  def self.show(params:, sinatra:, **)

    return PaymentVoucher::Cell::Voucher.( Claim::Row[params[:id]] ).()
    Claim::Cell::Show.( Claim::Row[params[:id]] ).()
  end

  def self.rezip(params:, sinatra:, **)
    result = Expense::Claim::Rezip.( params: params, archive_dir: "./downloads", upload_dir: "./uploads" )

    result.inspect

    # Claim::Cell::Show.( Claim::Row[params[:id]] ).()
  end
end

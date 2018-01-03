module Expense
  # Create a payment_voucher file.
  class Claim < Trailblazer::Operation
    def self.twin( ctx, model:, ** )
      ctx[:file] = ::Claim::Twin.new(model)
    end

    def self.save_zip( ctx, file:, zip:, ** )
      file.archive_path = zip
      file.save
    end

    step Model( ::Claim::Row, :new )
    step Contract::Build( constant: Form::Claim )
    step Contract::Validate()
    step Exp::Step::CreatedAt
    step Contract::Persist()
    step :serial_number!
    step :add_expenses!
    require_relative "pack"
    step method(:twin) # DISCUSS: why again?
    step Nested( ::Claim::Pack )
    step method(:save_zip)

    def add_expenses!(options, model:, **)
      options["contract.default"].expenses.each do |exp|
        model.add_expense exp.model
      end
    end

    def serial_number!(options, model:, **)
      # content_snapshot = Sequel.pg_jsonb_op(:content)

      # result = ::Claim::Row.where(content_snapshot.has_key?('serial_number'))#.reverse(:serial_number)
      # result.each do |r|
      #   puts r.content
      # raise
      # end
      serial_number = ::Claim::Row.max(:serial_number).to_i || 0
      serial_number += 1

      twin = ::Claim::Twin.new(model)

      twin.serial_number = serial_number
      twin.identifier    = "PV17-N-#{"%03d" % serial_number}-TT"
      twin.type          = "payment_voucher"

      twin.save
    end


    class Rezip < Trailblazer::Operation
      step Model( ::Claim::Row, :[] )
      step Claim.method(:twin)
      step Nested( ::Claim::Pack )
      step Claim.method(:save_zip)
    end
  end

  class File < Claim # FIXME: rename to Records::File, make serial number injectable
    def serial_number!( ctx, model:, type:, identifier:, serial_number:, ** )
      twin = ::Claim::Twin.new(model)

      twin.serial_number = serial_number
      twin.identifier    = identifier
      twin.type          = type

      twin.save
    end
  end
end

# http://sequel.jeremyevans.net/rdoc-plugins/files/lib/sequel/extensions/pg_json_ops_rb.html


# collection :expenses
#   find
#   add_to_graph

# validate expenses
#   authorize each expense "is from user, etc, not used before, etc"

# sync to Claim
# add expenses

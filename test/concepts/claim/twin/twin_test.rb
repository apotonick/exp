require "test_helper"

class ClaimTwinTest < Minitest::Spec
  before do
    Claim::Row.truncate
    File.delete( *Dir.glob("#{archive_dir}/*.zip") )
  end

  let(:upload_dir) { "./uploads/fixture" }
  let(:archive_dir) { "./test/downloads" }
  let(:expense_1) { factory( Expense::Create, params: { file_path: "trb.png",  invoice_number: "I1", source: "Biosk", unit_price: "10", currency: "AUD", folder_id: 1, txn_type: "expense", txn_account: "bank"} )[:model] }
  let(:expense_2) { factory( Expense::Create, params: { file_path: "epic.jpg", invoice_number: "I2", source: "At",    unit_price: "11",  currency: "AUD", folder_id: 1, txn_type: "expense", txn_account: "bank"} )[:model] }

  describe "Expense::Claim" do
    it do
      result     = Expense::Claim.( params: { expenses: [ expense_1.id, expense_2.id ] }, archive_dir: archive_dir, upload_dir: upload_dir )

      result.success?.must_equal true

      claim = result[:model]

      # did it persist?
      claim = Claim::Row[ claim.id ]

      claim.expenses[0] == expense_1
      claim.expenses[1] == expense_2
    end
  end

  # TODO: file {financial-year identifier/ust etc/sale/purchase/ paypal/bank/stripe}
  describe "File" do
    let(:file) { claim     = Expense::Claim.( params: { expenses: [ expense_1.id, expense_2.id ] }, archive_dir: archive_dir, upload_dir: upload_dir )[:model] }
    let(:twin) { twin      = Claim::Twin.new( file ) }

    # this twin goes into Cell::Voucher.

    it do
      twin.count.must_equal 2
      twin.expenses[0].effective_money.format.must_equal "$10.60"
      twin.expenses[1].effective_money.format.must_equal "$11.66"

      twin.expenses[0].effective_amount.must_equal "SGD $10.60"
      twin.expenses[1].effective_amount.must_equal "SGD $11.66"

      twin.expenses[0].index.must_equal "001"
      twin.expenses[1].index.must_equal "002"

      twin.effective_total_money.format.must_equal "$22.26"
      twin.effective_total.must_equal "SGD $22.26"

      assert twin.created_at > Time.now-10 # TODO: nicer date tests.
      assert twin.created_at <= Time.now

      assert twin.serial_number.to_i > 0
      twin.identifier.must_equal "PV17-N-00#{twin.serial_number}-TT"

      twin.type.must_equal "payment_voucher"
    end

    it "creates .zip" do
      twin.archive_path.must_equal "#{archive_dir}/PV17-N-00#{twin.serial_number}-TT.zip"

      zip_files_for(twin.archive_path).must_equal [["001-trb.png", 26916], ["002-epic.jpg", 221545]]
    end

    describe "Expense::Claim::Rezip" do
      it "only generates the .zip file for legacy claims" do
        twin.archive_path.must_equal "#{archive_dir}/PV17-N-00#{twin.serial_number}-TT.zip"

  pp twin.archive_path
        File.delete(twin.archive_path) # simulate a legacy claim without a ZIP.

        result = Expense::Claim::Rezip.( params: { id: twin.id }, archive_dir: archive_dir, upload_dir: upload_dir )

        result.success?.must_equal true


        file = result[:file]

        zip_files_for(file.archive_path).must_equal [["001-trb.png", 26916], ["002-epic.jpg", 221545]]

        twin.archive_path.must_equal "#{archive_dir}/PV17-N-00#{twin.serial_number}-TT.zip"
      end
    end

    describe "Expense::File" do
      let(:file) { claim     = Expense::File.( params: { expenses: [ expense_1.id, expense_2.id ] }, archive_dir: archive_dir, upload_dir: upload_dir, type: "purchase-paypal", serial_number: 1, identifier: "2017-purchase-paypal-1" )[:model] }
      let(:twin) { twin      = Claim::Twin.new( file ) }

      it "creates ZIP for arbitrary Records" do
        twin.archive_path.must_equal "#{archive_dir}/2017-purchase-paypal-1.zip"
        zip_files_for(twin.archive_path).must_equal [["001-trb.png", 26916], ["002-epic.jpg", 221545]]
      end
    end
  end

  def zip_files_for(path)
    zip_files = []

    Zip::File.open(path) do |zip_file|
      zip_file.each { |entry| zip_files << [entry.to_s, entry.size] }
    end

    zip_files
  end
end

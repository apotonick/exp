Sequel.migration do
  up do
    create_table(:payment_vouchers) do
      primary_key :id
      column :content, "jsonb"
      column :created_at, DateTime
      column :serial_number, String
    end
  end

  down do
    drop_table(:payment_vouchers)
  end
end

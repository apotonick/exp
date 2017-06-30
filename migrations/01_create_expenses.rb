Sequel.migration do
  up do
    create_table(:expenses) do
      primary_key :id
      column :role_id, Integer
      column :content, "jsonb"
      column :payment_voucher_id, Integer
    end
  end

  down do
    drop_table(:expenses)
  end
end

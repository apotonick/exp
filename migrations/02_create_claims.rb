Sequel.migration do
  up do
    create_table(:claims) do
      primary_key :id
      column :content, "jsonb"
      column :created_at, DateTime
      column :transaction_id, Integer#, null: true
    end
  end

  down do
    drop_table(:claims)
  end
end

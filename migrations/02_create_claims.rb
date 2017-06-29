Sequel.migration do
  up do
    create_table(:claims) do
      primary_key :id
      column :content, "jsonb"
      column :created_at, DateTime
    end

    add_column :expenses, :claim_id, Integer#, null: true
  end

  down do
    drop_table(:claims)
    drop_column :expenses, :claim_id
  end
end

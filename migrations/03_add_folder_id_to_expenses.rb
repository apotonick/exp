Sequel.migration do
  up do
    add_column :expenses, :folder_id, Integer
  end

  down do
    drop_column :expenses, :folder_id
  end
end

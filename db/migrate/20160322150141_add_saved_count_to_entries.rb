class AddSavedCountToEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :entries, :saved_count, :integer
  end
end

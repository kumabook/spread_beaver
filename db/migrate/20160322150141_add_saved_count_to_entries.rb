class AddSavedCountToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :saved_count, :integer
  end
end

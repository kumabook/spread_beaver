class ChangeSavedCountOfEntries < ActiveRecord::Migration
  def change
    change_column :entries, :saved_count, :integer, null: false, default: 0
  end
end

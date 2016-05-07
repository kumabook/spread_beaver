class RenameUserEntriesToSavedEntries < ActiveRecord::Migration
  def change
    rename_table :user_entries, :saved_entries
  end
end

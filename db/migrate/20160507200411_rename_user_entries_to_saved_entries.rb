class RenameUserEntriesToSavedEntries < ActiveRecord::Migration[4.2]
  def change
    rename_table :user_entries, :saved_entries
  end
end

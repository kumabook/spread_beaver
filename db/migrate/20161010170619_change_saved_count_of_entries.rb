# frozen_string_literal: true
class ChangeSavedCountOfEntries < ActiveRecord::Migration[4.2]
  def change
    change_column :entries, :saved_count, :integer, null: false, default: 0
  end
end

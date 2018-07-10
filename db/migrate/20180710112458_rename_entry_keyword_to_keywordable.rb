# frozen_string_literal: true

class RenameEntryKeywordToKeywordable < ActiveRecord::Migration[5.1]
  def change
    rename_table :entry_keywords, :keywordables
    rename_column :keywordables, :entry_id, :keywordable_id
    add_column :keywordables, :keywordable_type, :string, null: false, default: "Entry"
  end
end

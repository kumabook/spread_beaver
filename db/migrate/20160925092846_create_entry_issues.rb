# frozen_string_literal: true
class CreateEntryIssues < ActiveRecord::Migration[4.2]
  def change
    create_table :entry_issues do |t|
      t.string  :entry_id  , null: false
      t.uuid    :issue_id, null: false
      t.integer :engagement, null: false, default: 0

      t.timestamps null: false
    end
    add_index :entry_issues, %i[entry_id issue_id], unique: true
  end
end

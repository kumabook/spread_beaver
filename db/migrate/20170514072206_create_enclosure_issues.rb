# frozen_string_literal: true

class CreateEnclosureIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :enclosure_issues do |t|
      t.string  :enclosure_type, null: false
      t.uuid    :enclosure_id  , null: false
      t.uuid    :issue_id      , null: false
      t.integer :engagement    , null: false, default: 0
      t.timestamps
    end
    add_index :enclosure_issues, %i[enclosure_id issue_id], unique: true
  end
end

class CreateEntryIssues < ActiveRecord::Migration
  def change
    create_table :entry_issues do |t|
      t.string  :entry_id  , null: false
      t.uuid    :issue_id, null: false
      t.integer :engagement, null: false, default: 0

      t.timestamps null: false
    end
    add_index :entry_issues, [:entry_id, :issue_id], unique: true
  end
end

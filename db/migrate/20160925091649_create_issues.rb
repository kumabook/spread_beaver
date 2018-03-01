class CreateIssues < ActiveRecord::Migration[4.2]
  def change
    create_table :issues, id: :uuid, force: true do |t|
      t.string  :label      , null: false
      t.text    :description, null: true
      t.integer :state      , null: false, default: 0
      t.uuid    :journal_id , null: false, foreign_key: true

      t.timestamps null: false
    end
    add_index :issues, [:id]                , unique: true
    add_index :issues, [:journal_id, :label], unique: true
  end
end

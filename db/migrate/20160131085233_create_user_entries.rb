class CreateUserEntries < ActiveRecord::Migration
  def change
    create_table :user_entries do |t|
      t.integer :user_id, null: false
      t.string :entry_id, null: false

      t.timestamps null: false
    end
    add_index :user_entries, [:user_id, :entry_id], unique: true
  end
end

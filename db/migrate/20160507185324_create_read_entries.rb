class CreateReadEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :read_entries do |t|
      t.uuid   :user_id, null: false
      t.string :entry_id, null: false

      t.timestamps null: false
    end
    add_index :read_entries, [:user_id, :entry_id], unique: true
  end
end

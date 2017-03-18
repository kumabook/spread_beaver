class CreateLikedEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :liked_entries do |t|
      t.uuid   :user_id , null: false
      t.string :entry_id, null: false

      t.timestamps null: false
    end
    add_index :liked_entries, [:user_id, :entry_id], unique: true

    add_column :entries, :likes_count, :integer
  end
end

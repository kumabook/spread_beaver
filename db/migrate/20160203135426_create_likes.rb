class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :user_id,  null: false
      t.uuid :track_id, null: false

      t.timestamps null: false
    end
    add_index :likes, [:user_id, :track_id], unique: true
  end
end

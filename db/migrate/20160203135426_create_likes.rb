# frozen_string_literal: true

class CreateLikes < ActiveRecord::Migration[4.2]
  def change
    create_table :likes do |t|
      t.uuid :user_id,  null: false
      t.uuid :track_id, null: false

      t.timestamps null: false
    end
    add_index :likes, %i[user_id track_id], unique: true
  end
end

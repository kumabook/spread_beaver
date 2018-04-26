# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.uuid   :user_id, null: false
      t.string :feed_id,  null: false

      t.timestamps null: false
    end
    add_index :subscriptions, %i[user_id feed_id], unique: true
  end
end

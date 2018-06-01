# frozen_string_literal: true

class CreateAuthentications < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :twitter_user_id
    create_table :authentications do |t|
      t.uuid :user_id  , null: false, foreign_key: true
      t.integer :provider, null: false
      t.string :uid, null: false
      t.string :name
      t.string :nickname
      t.string :email
      t.string :url
      t.string :image_url
      t.string :description
      t.text :others
      t.text :credentials
      t.text :raw_info
      t.timestamps null: false
    end

    add_index :authentications, :provider
    add_index :authentications, %i[user_id provider], unique: true
    add_index :authentications, %i[provider uid], unique: true
  end
end

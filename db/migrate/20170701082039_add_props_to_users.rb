# frozen_string_literal: true

class AddPropsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name           , :string
    add_column :users, :picture        , :string
    add_column :users, :locale         , :string
    add_column :users, :twitter_user_id, :string

    add_index :users, :name           , unique: true
    add_index :users, :twitter_user_id, unique: true
  end
end

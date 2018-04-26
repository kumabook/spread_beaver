# frozen_string_literal: true

class CreateUserEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :user_entries do |t|
      t.uuid   :user_id, null: false
      t.string :entry_id, null: false

      t.timestamps null: false
    end
    add_index :user_entries, %i[user_id entry_id], unique: true
  end
end

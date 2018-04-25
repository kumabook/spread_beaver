# frozen_string_literal: true
class CreatePreferences < ActiveRecord::Migration[4.2]
  def change
    create_table :preferences do |t|
      t.uuid   :user_id,  null: false
      t.string :key    ,  null: false
      t.text   :value  ,  null: false

      t.timestamps null: false
    end
    add_index :preferences, [:user_id, :key], unique: true
  end
end

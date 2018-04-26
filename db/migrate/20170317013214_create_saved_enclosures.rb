# frozen_string_literal: true

class CreateSavedEnclosures < ActiveRecord::Migration[5.0]
  def change
    create_table :saved_enclosures do |t|
      t.uuid   :user_id       , null: false
      t.uuid   :enclosure_id  , null: false
      t.string :enclosure_type, null: false

      t.timestamps null: false
    end
    add_index :saved_enclosures, %i[user_id enclosure_id], unique: true

    add_column :enclosures, :saved_count, :integer, null: false, default: 0
  end
end

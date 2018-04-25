# frozen_string_literal: true
class CreatePlayedEnclosures < ActiveRecord::Migration[5.0]
  def change
    create_table :played_enclosures do |t|
      t.uuid   :user_id       , null: false
      t.uuid   :enclosure_id  , null: false
      t.string :enclosure_type, null: false

      t.timestamps null: false
    end
    add_index :played_enclosures, [:user_id, :enclosure_id], unique: false

    add_column :enclosures, :play_count, :integer, null: false, default: 0
  end
end

# frozen_string_literal: true
class CreatePick < ActiveRecord::Migration[5.1]
  def change
    create_table :picks do |t|
      t.uuid   :enclosure_id  , null: false
      t.string :enclosure_type, null: false
      t.uuid   :container_id  , null: false
      t.string :container_type, null: false

      t.timestamps null: false
    end
    add_index :picks, [:enclosure_id, :container_id], unique: true
    add_index :picks, :created_at
    add_index :picks, :updated_at
  end
end

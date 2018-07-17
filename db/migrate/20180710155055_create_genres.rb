# frozen_string_literal: true

class CreateGenres < ActiveRecord::Migration[5.1]
  def change
    create_table :genres do |t|
      t.string :label, null: false
      t.string :japanese_label
    end
    add_index :genres, [:label]

    create_table :genre_items do |t|
      t.integer :genre_id, null: false
      t.uuid :genre_item_id, null: false
      t.string :genre_item_type, null: false
    end
    add_index :genre_items, [:genre_id, :genre_item_id]
  end
end

# frozen_string_literal: true

class CreateArtists < ActiveRecord::Migration[5.1]
  def change
    create_table :artists, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name, default: ""
      t.integer :provider, default: 0
      t.string :identifier, null: false, default: ""
      t.string :url, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :thumbnail_url
      t.string :artwork_url

      t.integer :entries_count, default: 0, null: false

      t.integer :likes_count, default: 0, null: false
      t.integer :saved_count, default: 0, null: false
      t.integer :play_count, default: 0, null: false

      t.timestamps null: false
      t.index [:provider]
      t.index [:name]
    end
  end
end

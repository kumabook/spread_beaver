# frozen_string_literal: true

class CreateEnclosureArtists < ActiveRecord::Migration[5.1]
  def change
    create_table :enclosure_artists do |t|
      t.uuid   :enclosure_id  , null: false
      t.string :enclosure_type, null: false
      t.uuid   :artist_id, null: false

      t.timestamps null: false
    end
    add_index :enclosure_artists, %i[enclosure_id artist_id], unique: true
    add_index :enclosure_artists, :created_at
    add_index :enclosure_artists, :updated_at
  end
end

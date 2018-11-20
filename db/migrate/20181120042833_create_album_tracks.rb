# frozen_string_literal: true

class CreateAlbumTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :album_tracks do |t|
      t.uuid   :album_id  , null: false
      t.uuid   :track_id, null: false

      t.timestamps null: false
    end
    add_index :album_tracks, %i[album_id track_id], unique: true
    add_index :album_tracks, :created_at
    add_index :album_tracks, :updated_at
  end
end

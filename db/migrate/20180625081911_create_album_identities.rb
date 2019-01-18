# frozen_string_literal: true

class CreateAlbumIdentities < ActiveRecord::Migration[5.1]
  def change
    create_table :album_identities, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name, null: false
      t.string :artist_name, null: false
      t.string :slug, null: false

      t.integer :entries_count, default: 0, null: false

      t.integer :likes_count, default: 0, null: false
      t.integer :saved_count, default: 0, null: false
      t.integer :play_count, default: 0, null: false

      t.timestamps null: false

      t.index [:name]
      t.index [:name, :artist_name], unique: true
      t.index [:slug], unique: true
    end
    create_table :album_track_identities do |t|
      t.uuid :album_identity_id, null: false
      t.uuid :track_identity_id, null: false
      t.index [:album_identity_id, :track_identity_id], unique: true, name: "index_album_track_identities"
    end
    add_column :albums, :identity_id, :uuid
    add_index :albums, :identity_id
  end
end

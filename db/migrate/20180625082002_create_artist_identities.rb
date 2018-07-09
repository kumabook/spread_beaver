# frozen_string_literal: true

class CreateArtistIdentities < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_identities, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name, null: false
      t.string :origin_name, null: false

      t.integer :entries_count, default: 0, null: false

      t.integer :likes_count, default: 0, null: false
      t.integer :saved_count, default: 0, null: false
      t.integer :play_count, default: 0, null: false
      t.timestamps null: false

      t.index [:name]
    end
    create_table :track_artist_identities do |t|
      t.uuid :track_identity_id, null: false
      t.uuid :artist_identity_id, null: false
      t.index [:track_identity_id, :artist_identity_id], unique: true, name: "index_track_artist_identities"
    end
    create_table :album_artist_identities do |t|
      t.uuid :album_identity_id, null: false
      t.uuid :artist_identity_id, null: false
      t.index [:album_identity_id, :artist_identity_id], unique: true, name: "index_album_artist_identities"
    end
    add_column :artists, :identity_id, :uuid
    add_index :artists, :identity_id
  end
end

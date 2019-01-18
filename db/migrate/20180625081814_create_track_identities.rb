# frozen_string_literal: true

class CreateTrackIdentities < ActiveRecord::Migration[5.1]
  def change
    create_table :track_identities, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string :name, null: false
      t.string :artist_name, null: false
      t.string :slug, null: false

      t.integer :entries_count, default: 0, null: false

      t.integer :likes_count, default: 0, null: false
      t.integer :saved_count, default: 0, null: false
      t.integer :play_count, default: 0, null: false
      t.integer :pick_count, default: 0, null: false

      t.timestamps null: false

      t.index [:name]
      t.index [:name, :artist_name], unique: true
      t.index [:slug], unique: true
    end
    add_column :tracks, :identity_id, :uuid
    add_index :tracks, :identity_id
  end
end

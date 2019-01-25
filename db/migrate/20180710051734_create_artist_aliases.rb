# frozen_string_literal: true

class CreateArtistAliases < ActiveRecord::Migration[5.1]
  def change
    create_table :artist_aliases do |t|
      t.uuid :artist_identity_id, null: false
      t.string :name, null: false
    end
    add_index :artist_aliases, [:name]
    add_index :artist_aliases, %i[artist_identity_id name], unique: true
  end
end

# frozen_string_literal: true

class RecreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.integer :provider, null: false, default: 0
      t.string :identifier, null: false, default: ""
      t.string :owner_id
      t.string :owner_name
      t.string :url, null: false, default: ""
      t.string :title, null: false, default: ""
      t.string :description
      t.string :thumbnail_url
      t.string :artwork_url
      t.string :audio_url
      t.integer :duration
      t.timestamp :published_at
      t.string :state

      t.integer :entries_count, default: 0, null: false
      t.integer :pick_count, default: 0, null: false

      t.integer :likes_count, default: 0, null: false
      t.integer :saved_count, default: 0, null: false
      t.integer :play_count, default: 0, null: false

      t.timestamps null: false
      t.index [:provider]
      t.index [:title]
    end
  end
end

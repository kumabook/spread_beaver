# frozen_string_literal: true
class CreateEntryTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :entry_tracks do |t|
      t.string :entry_id, null: false
      t.uuid   :track_id, null: false

      t.timestamps null: false
    end
    add_index :entry_tracks, [:entry_id, :track_id], unique: true
  end
end

class CreateEntryTracks < ActiveRecord::Migration
  def change
    create_table :entry_tracks do |t|
      t.string :entry_id
      t.integer :track_id

      t.timestamps null: false
    end
  end
end

class CreateEntryTracks < ActiveRecord::Migration
  def change
    create_table :entry_tracks do |t|
      t.string :entry_id,  null: false
      t.integer :track_id, null: false

      t.timestamps null: false
    end
  end
end

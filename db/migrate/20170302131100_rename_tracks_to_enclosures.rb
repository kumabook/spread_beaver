class RenameTracksToEnclosures < ActiveRecord::Migration[5.0]
  def change
    rename_table :tracks      , :enclosures
    rename_table :track_likes , :liked_enclosures
    rename_table :entry_tracks, :entry_enclosures

    add_column :enclosures      , :type, :string, null: false, default: 'Track'
    add_column :liked_enclosures, :enclosure_type, :string, null: false, default: 'Track'
    add_column :entry_enclosures, :enclosure_type, :string, null: false, default: 'Track'

    add_index :enclosures      , :type
    add_index :liked_enclosures, :enclosure_type
    add_index :entry_enclosures, :enclosure_type

    rename_column :enclosures, :like_count, :likes_count
    remove_column :enclosures, :provider  , :string
    remove_column :enclosures, :identifier, :string

    rename_column :liked_enclosures, :track_id  , :enclosure_id
    rename_column :entry_enclosures, :track_id  , :enclosure_id
  end
end

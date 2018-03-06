class AddEntriesCountToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :entries_count, :integer, null: false, default: 0
  end
end

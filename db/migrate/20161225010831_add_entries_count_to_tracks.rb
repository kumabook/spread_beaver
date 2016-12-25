class AddEntriesCountToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :entries_count, :integer, null: false, default: 0
  end
end

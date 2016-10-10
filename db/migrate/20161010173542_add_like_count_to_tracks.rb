class AddLikeCountToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :like_count, :integer, null: false, default: 0
  end
end

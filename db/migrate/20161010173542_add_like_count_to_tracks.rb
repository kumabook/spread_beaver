# frozen_string_literal: true
class AddLikeCountToTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :tracks, :like_count, :integer, null: false, default: 0
  end
end

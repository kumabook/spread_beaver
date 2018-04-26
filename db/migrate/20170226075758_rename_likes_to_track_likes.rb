# frozen_string_literal: true

class RenameLikesToTrackLikes < ActiveRecord::Migration[5.0]
  def change
    rename_table :likes, :track_likes
  end
end

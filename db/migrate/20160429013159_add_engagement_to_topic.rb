# frozen_string_literal: true
class AddEngagementToTopic < ActiveRecord::Migration[4.2]
  def change
    add_column :topics, :engagement, :integer, null: false, default: 0
  end
end

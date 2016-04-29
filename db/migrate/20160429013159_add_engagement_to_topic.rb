class AddEngagementToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :engagement, :integer, :null => false, :default => 0
  end
end

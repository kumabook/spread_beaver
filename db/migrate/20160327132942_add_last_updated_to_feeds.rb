class AddLastUpdatedToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :lastUpdated, :timestamp
  end
end

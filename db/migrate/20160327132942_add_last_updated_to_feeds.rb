class AddLastUpdatedToFeeds < ActiveRecord::Migration[4.2]
  def change
    add_column :feeds, :lastUpdated, :timestamp
  end
end

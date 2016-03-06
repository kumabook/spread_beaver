class AddCrawledToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :crawled, :timestamp
  end
end

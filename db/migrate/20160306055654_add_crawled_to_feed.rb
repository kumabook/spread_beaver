# frozen_string_literal: true
class AddCrawledToFeed < ActiveRecord::Migration[4.2]
  def change
    add_column :feeds, :crawled, :timestamp
  end
end

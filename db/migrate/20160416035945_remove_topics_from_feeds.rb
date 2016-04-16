class RemoveTopicsFromFeeds < ActiveRecord::Migration
  def change
    remove_column :feeds, :topics, :string
  end
end

class RemoveTopicsFromFeeds < ActiveRecord::Migration[4.2]
  def change
    remove_column :feeds, :topics, :string
  end
end

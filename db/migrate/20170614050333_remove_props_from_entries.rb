class RemovePropsFromEntries < ActiveRecord::Migration[5.0]
  def change
    remove_column :entries, :unread
    remove_column :entries, :actionTimestamp
    remove_column :entries, :sid
    remove_column :entries, :categories
  end
end

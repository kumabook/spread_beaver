class IndexEntries < ActiveRecord::Migration[5.0]
  def change
    add_index :entries, :crawled
    add_index :entries, :recrawled
    add_index :entries, :published
    add_index :entries, :updated
    add_index :entries, :feed_id
  end
end

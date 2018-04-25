# frozen_string_literal: true
class CreateEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :entries, id: false do |t|
      t.string    :id
      t.string    :title
      t.text      :content
      t.text      :summary
      t.text      :author

      t.text      :alternate
      t.text      :origin
      t.text      :keywords
      t.text      :visual
      t.text      :tags
      t.text      :categories
      t.boolean   :unread,         :null => false
      t.integer   :engagement
      t.integer   :actionTimestamp
      t.text      :enclosure
      t.text      :fingerprint,   :null => false
      t.string    :originId,      :null => false
      t.string    :sid

      t.timestamp :crawled
      t.timestamp :recrawled
      t.timestamp :published
      t.timestamp :updated


      t.timestamps null: false
      t.string :feed_id, :null => false
    end
    add_index :entries, :id, unique: true
  end
end

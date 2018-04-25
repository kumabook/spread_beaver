# frozen_string_literal: true
class CreateFeedTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :feed_topics do |t|
      t.string :feed_id
      t.string :topic_id

      t.timestamps null: false
    end
    add_index :feed_topics, %i[feed_id topic_id], unique: true
  end
end

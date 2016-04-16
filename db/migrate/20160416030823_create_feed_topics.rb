class CreateFeedTopics < ActiveRecord::Migration
  def change
    create_table :feed_topics do |t|
      t.string :feed_id
      t.string :topic_id

      t.timestamps null: false
    end
    add_index :feed_topics, [:feed_id, :topic_id], unique: true
  end
end

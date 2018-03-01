class CreateFeeds < ActiveRecord::Migration[4.2]
  def change
    create_table :feeds, id: false do |t|
      t.string  :id, :null => false
      t.string  :title
      t.text    :description
      t.string  :website
      t.string  :visualUrl
      t.string  :coverUrl
      t.string  :iconUrl
      t.string  :language
      t.string  :partial
      t.string  :coverColor
      t.string  :contentType
      t.integer :subscribers
      t.float   :velocity
      t.string  :topics

      t.timestamps null: false
    end
    add_index :feeds, :id, unique: true
  end
end

class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries, id: false do |t|
      t.string :id
      t.string :title
      t.text :content
      t.text :summary
      t.timestamp :published
      t.string :url
      t.string :thumbnail_url

      t.timestamps null: false
    end
  end
end

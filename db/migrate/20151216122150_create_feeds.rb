class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds, id: false do |t|
      t.string :id
      t.string :title
      t.text :description
      t.string :website

      t.timestamps null: false
    end
  end
end

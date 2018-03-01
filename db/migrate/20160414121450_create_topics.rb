class CreateTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :topics, id: false, force: true do |t|
      t.string :id         , null: false
      t.string :label      , null: false
      t.string :description, null: true

      t.timestamps null: false
    end
    add_index :topics, [:id], unique: true
    add_index :topics, [:label], unique: true
  end
end

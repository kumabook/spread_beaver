class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics, id: false, force: true do |t|
      t.string :id   , null: false
      t.string :label, null: false

      t.timestamps null: false
    end
    add_index :topics, [:id], unique: true
    add_index :topics, [:label], unique: true
  end
end

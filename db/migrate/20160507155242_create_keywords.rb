class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords, id: false, force: true do |t|
      t.string :id         , null: false
      t.string :label      , null: false
      t.text   :description, null: true

      t.timestamps null: false
    end
    add_index :keywords, [:id]   , unique: true
    add_index :keywords, [:label], unique: true
  end
end

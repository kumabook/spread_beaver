class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories, id: false do |t|
      t.string :id          , null: false
      t.string :label       , null: false
      t.string :description , null: true
      t.uuid   :user_id     , null: false

      t.timestamps null: false
    end
    add_index :categories, [:id]   , unique: true
    add_index :categories, [:label], unique: true
  end
end

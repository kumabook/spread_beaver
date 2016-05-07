class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags, id: false, force: true do |t|
      t.string :id      , null: false
      t.string :user_id , null: false
      t.string :label   , null: false
      t.text   :description

      t.timestamps null: false
    end
    add_index :tags, [:id], unique: true
    add_index :tags, [:user_id, :label], unique: true
  end
end
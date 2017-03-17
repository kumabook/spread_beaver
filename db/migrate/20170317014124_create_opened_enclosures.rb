class CreateOpenedEnclosures < ActiveRecord::Migration[5.0]
  def change
    create_table :opened_enclosures do |t|
      t.uuid   :user_id       , null: false
      t.string :enclosure_id  , null: false
      t.string :enclosure_type, null: false

      t.timestamps null: false
    end
    add_index :opened_enclosures, [:user_id, :enclosure_id], unique: true

    add_column :enclosures, :opened_count, :integer
  end
end

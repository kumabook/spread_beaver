class CreateEntryKeywords < ActiveRecord::Migration
  def change
    create_table :entry_keywords do |t|
      t.string :entry_id,   null: false
      t.string :keyword_id, null: false

      t.timestamps null: false
    end
    add_index :entry_keywords, [:entry_id, :keyword_id], unique: true
  end
end

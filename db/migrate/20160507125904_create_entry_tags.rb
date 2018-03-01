class CreateEntryTags < ActiveRecord::Migration[4.2]
  def change
    create_table :entry_tags do |t|
      t.string :tag_id
      t.string :entry_id

      t.timestamps null: false
    end
  end
end

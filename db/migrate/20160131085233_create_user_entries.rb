class CreateUserEntries < ActiveRecord::Migration
  def change
    create_table :user_entries do |t|
      t.integer :user_id
      t.string :entry_id

      t.timestamps null: false
    end
  end
end

class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals, id: :uuid, force: true do |t|
      t.string :stream_id, null: false
      t.string :label,     null: false
      t.text   :description

      t.timestamps null: false
    end
    add_index :journals, [:id]       , unique: true
    add_index :journals, [:label]    , unique: true
  end
end

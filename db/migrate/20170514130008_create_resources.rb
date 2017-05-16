class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.string  :wall_id      , null: false
      t.string  :resource_id  , null: false
      t.integer :resource_type, null: false
      t.integer :engagement   , null: false, default: 0

      t.timestamps
    end
  end
end

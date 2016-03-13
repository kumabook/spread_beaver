class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.uuid   :user_id, null: false
      t.string :feed_id,  null: false

      t.timestamps null: false
    end
    add_index :subscriptions, [:user_id, :feed_id], unique: true
  end
end

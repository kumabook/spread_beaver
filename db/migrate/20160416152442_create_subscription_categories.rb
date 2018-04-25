# frozen_string_literal: true
class CreateSubscriptionCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :subscription_categories do |t|
      t.integer :subscription_id
      t.string  :category_id

      t.timestamps null: false
    end
    add_index :subscription_categories, [:subscription_id, :category_id],
              unique: true, name: "subscription_categories_index"
  end
end

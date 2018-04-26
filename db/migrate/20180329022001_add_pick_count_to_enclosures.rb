# frozen_string_literal: true

class AddPickCountToEnclosures < ActiveRecord::Migration[5.1]
  def change
    add_column :enclosures, :pick_count, :integer, null: false, default: 0
  end
end

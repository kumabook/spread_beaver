# frozen_string_literal: true
class AddEngagementToEntryEnclosures < ActiveRecord::Migration[5.0]
  def change
    add_column :entry_enclosures, :engagement, :integer, default: 0, null: false
  end
end

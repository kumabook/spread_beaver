# frozen_string_literal: true
class AddIndexToEntryEnclosure < ActiveRecord::Migration[5.0]
  def change
    add_index :entry_enclosures, :entry_id
    add_index :entry_enclosures, :enclosure_id
  end
end

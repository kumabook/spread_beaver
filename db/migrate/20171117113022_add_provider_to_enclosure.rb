# frozen_string_literal: true
require "pink_spider"

class AddProviderToEnclosure < ActiveRecord::Migration[5.0]
  def up
    add_column :enclosures, :provider, :integer, default: 0
    add_column :enclosures, :title, :string, default: ""
    add_index :enclosures, :title, unique: false
    add_index :enclosures, :provider, unique: false
  end

  def down
    remove_column :enclosures, :provider
  end
end

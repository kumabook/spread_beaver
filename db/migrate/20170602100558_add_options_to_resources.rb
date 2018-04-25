# frozen_string_literal: true
class AddOptionsToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :resources, :options, :text
  end
end

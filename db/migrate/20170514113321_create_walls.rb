# frozen_string_literal: true
class CreateWalls < ActiveRecord::Migration[5.0]
  def change
    create_table :walls do |t|
      t.string :label
      t.string :description

      t.timestamps
    end
  end
end

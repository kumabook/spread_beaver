# frozen_string_literal: true
class AddLocaleToTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :locale, :string
    add_index :topics, :locale, unique: false
  end
end

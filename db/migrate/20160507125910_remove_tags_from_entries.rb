# frozen_string_literal: true

class RemoveTagsFromEntries < ActiveRecord::Migration[4.2]
  def change
    remove_column :entries, :tags, :string
  end
end

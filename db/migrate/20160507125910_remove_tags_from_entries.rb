class RemoveTagsFromEntrys < ActiveRecord::Migration
  def change
    remove_column :entries, :tags, :string
  end
end

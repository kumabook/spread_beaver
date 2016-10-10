class AddReadCountToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :read_count, :integer, null: false, default: 0
  end
end

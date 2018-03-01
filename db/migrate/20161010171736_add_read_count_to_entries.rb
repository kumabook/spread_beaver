class AddReadCountToEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :entries, :read_count, :integer, null: false, default: 0
  end
end

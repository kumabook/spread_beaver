class AddEnclosureProviderToEntryEnclosure < ActiveRecord::Migration[5.0]
  def change
    add_column :entry_enclosures, :enclosure_provider, :integer, default: 0
    batch_size = 1000
    EntryEnclosure.all.preload(:enclosure).find_each(batch_size: batch_size) do |entry_enclosure|
      entry_enclosure.update_column(:enclosure_provider, entry_enclosure.enclosure.provider)
    end
  end
end

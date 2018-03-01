class CreateTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :tracks, id: :uuid, default: "uuid_generate_v4()", force: true do |t|
      t.string :identifier
      t.string :provider
      t.string :title
      t.string :url

      t.timestamps null: false
    end
    add_index :tracks, :id                     , unique: true
    add_index :tracks, [:provider, :identifier], unique: true
  end
end

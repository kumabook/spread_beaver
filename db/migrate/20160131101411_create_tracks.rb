class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :identifier
      t.string :provider
      t.string :title
      t.string :url

      t.timestamps null: false
    end
    add_index :tracks, [:provider, :identifier], unique: true
  end
end

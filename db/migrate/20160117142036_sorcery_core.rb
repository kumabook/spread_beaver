class SorceryCore < ActiveRecord::Migration[4.2]
  def change
    enable_extension 'uuid-ossp'
    create_table :users, id: :uuid, default: "uuid_generate_v4()", force: true do |t|
      t.string :email,            :null => false
      t.string :crypted_password
      t.string :salt

      t.timestamps
    end

    add_index :users, :id   , unique: true
    add_index :users, :email, unique: true
  end
end

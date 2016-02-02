class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :name
      t.string :ip_addr
      t.integer :netmask_len
      t.integer :ram
      t.integer :storage
      t.integer :cpunodes

      t.timestamps null: false
    end
  end
end

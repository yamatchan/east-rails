class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.integer :user_id
      t.integer :host_id
      t.string :name
      t.string :instance_name
      t.integer :cpu
      t.integer :ram
      t.string :ip_addr
      t.string :mac_addr
      t.string :os
      t.integer :status # stoped: 0, running: 1

      t.timestamps null: false
    end
  end
end

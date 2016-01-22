class CreateBridges < ActiveRecord::Migration
  def change
    create_table :bridges do |t|
      t.integer :user_id
      t.string :name

      t.timestamps null: false
    end
  end
end

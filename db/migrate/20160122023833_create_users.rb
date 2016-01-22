class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :id_str
      t.string :password

      t.timestamps null: false
    end
  end
end

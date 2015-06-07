class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :my_pocket_id, :null => false
      t.string :email_address
      t.string :password
      t.string :remarks

      t.timestamps
    end

    add_index :users, :my_pocket_id, unique: true
  end
end

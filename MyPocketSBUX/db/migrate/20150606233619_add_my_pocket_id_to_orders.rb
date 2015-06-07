class AddMyPocketIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :my_pocket_id, :string, :null => false, :default => ""
    #change_column :orders, :my_pocket_id, :string, null: false, default: ""
  end
end

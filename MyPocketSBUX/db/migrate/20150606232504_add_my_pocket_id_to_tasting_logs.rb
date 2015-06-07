class AddMyPocketIdToTastingLogs < ActiveRecord::Migration
  def change
    add_column :tasting_logs, :my_pocket_id, :string, :null => false, :default => ""
    #change_column :tasting_logs, :my_pocket_id, :string, null: false, default: ""
  end
end

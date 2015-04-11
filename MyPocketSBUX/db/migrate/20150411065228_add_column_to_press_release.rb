class AddColumnToPressRelease < ActiveRecord::Migration
  def change
    add_column :press_releases, :issue_date, :date
  end
end

class ChangeTypeOfStartTimeAndEndTimeInSeminars < ActiveRecord::Migration
  def change
    change_column :seminars, :start_time, :datetime
    change_column :seminars, :end_time, :datetime
  end
end

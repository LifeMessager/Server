class AddAlertTimeToUser < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :users, :alert_time, :datetime
        User.unscoped.find_each do |user|
          user.alert_time = '08:00'
          user.save! validate: false
        end
        change_column :users, :alert_time, :datetime, null: false
      end

      dir.down do
        remove_column :users, :alert_time, :datetime
      end
    end
  end
end

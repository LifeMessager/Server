class ChangeAlertTimeFromUser < ActiveRecord::Migration
  def up
    rename_column :users, :alert_time, :old_alert_time
    add_column :users, :alert_time, :string, null: false, default: '08:00'
    User.unscoped.find_each do |user|
      user.alert_time = user.old_alert_time.in_time_zone(user.timezone).to_s :time
      user.save!
    end
    remove_column :users, :old_alert_time
  end

  def down
    rename_column :users, :alert_time, :old_alert_time
    add_column :users, :alert_time, :datetime
    User.unscoped.find_each do |user|
      user.alert_time = user.timezone.parse "2014-01-01 #{user.old_alert_time}"
      user.save!
    end
    remove_column :users, :old_alert_time
    change_column :users, :alert_time, :datetime, null: false
  end
end

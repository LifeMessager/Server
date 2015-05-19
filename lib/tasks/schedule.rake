
def log task_name, content
  puts "[schedule:#{task_name}] (#{Time.now.inspect}) #{content}"
end

namespace :schedule do

desc 'Schedule to send tomorrow mail to all alertable users'
task :mail_daily => :environment do
  if User.all_alertable.empty?
    log 'mail_hourly', 'No alertable user'
  else
    log 'mail_hourly', '===================== Schedule alert user start ====================='
    User.all_alertable.find_each do |user|
      DiaryMailer.daily(user).deliver_later! wait_until: user.alert_time_for_tomorrow
      log 'mail_hourly', "Schedule alert user #{user.email} at #{user.alert_time_for_tomorrow} finished"
    end
    log 'mail_hourly', '===================== Schedule alert user finished =================='
  end
end

desc 'Check destroyable user daily'
task :delete_user_daily => :environment do
  if User.really_destroyable.empty?
    log 'delete_user_daily', 'No destroyable users'
  else
    log 'delete_user_daily', '==================== Destroy user start ===================='
    User.really_destroyable.find_each do |user|
      user.really_destroy!
      log 'delete_user_daily', "Destroy user #{user.email} finished"
    end
    log 'delete_user_daily', '==================== Destroy user finished ================='
  end
end

end

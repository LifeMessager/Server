
def log task_name, content
  puts "[schedule:#{task_name}] (#{Time.now.inspect}) #{content}"
end

namespace :schedule do

desc 'Send mail to current hour alertable users'
task :mail_hourly => :environment do
  if User.alertable.empty?
    log 'mail_hourly', 'No alertable user'
  else
    log 'mail_hourly', 'Alert user start'
    User.alertable.find_each do |user|
      DiaryMailer.daily(user).deliver!
      log 'mail_hourly', "Alert user #{user.email} finished"
    end
    log 'mail_hourly', 'Alert user all finished'
  end
end

desc 'Check destroyable user daily'
task :delete_user_daily => :environment do
  if User.really_destroyable.empty?
    log 'delete_user_daily', 'No destroyable users'
  else
    log 'delete_user_daily', 'Destroy user start'
    User.really_destroyable.find_each do |user|
      user.really_destroy!
      log 'delete_user_daily', "Destroy user #{user.email} finished"
    end
  end
end

end

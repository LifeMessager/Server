
def log task_name, content
  puts "[schedule:#{task_name}] (#{Time.now.inspect}) #{content}"
end

namespace :schedule do

desc 'Send mail to current hour alertable users'
task :mail_hourly => :environment do
  if User.alertable(Time.parse('08:00')).length < 1
    log 'mail_hourly', 'No alertable user'
  else
    log 'mail_hourly', 'Alert user started'
    User.alertable(Time.parse('08:00')).find_each do |user|
      begin
        DiaryMailer.daily(user).deliver!
        log 'mail_hourly', "Alert user #{user.email} finished"
      rescue => error
        log 'mail_hourly', "Alert user #{user.email} failed: \n #{error.backtrace}"
      end
    end
    log 'mail_hourly', 'Alert user all finished'
  end
end

end

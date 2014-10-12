
job_type :shell_with_env, "cd :path && source .env && bin/rails runner -e :environment \":task\" :output"

every 2.hours do
  shell_with_env 'DiaryMailer.daily(User.all.sample).deliver', :output => "log/crontab.log", :environment => "development"
end

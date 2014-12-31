
job_type :shell_with_env, "cd :path && source .env && bin/rails runner -e :environment \":task\" :output"
job_type :rake_with_env , "cd :path && source .env && :environment_variable=:environment bin/rake :task --silent :output"

every 1.hours do
  rake_with_env 'schedule:mail_hourly', :output => "log/crontab.log"
end

every 1.days do
  rake_with_env 'schedule:delete_user_daily', :output => "log/crontab.log"
end

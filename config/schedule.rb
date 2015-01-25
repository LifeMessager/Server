
job_type :shell_with_env, "cd :path && source .env && bin/rails runner -e :environment \":task\" :output"
job_type :rake_with_env , "cd :path && source .env && :environment_variable=:environment bin/rake :task --silent :output"

every :hour do
  rake_with_env 'schedule:mail_hourly', output: 'log/crontab.log'
end

every :day do
  rake_with_env 'schedule:delete_user_daily', output: 'log/crontab.log'
end

every :day, at: '20:00' do
  command_string = <<-SHELL
    echo "=================== Start Backup Database ==================";
    hash backup && backup perform -t backup_db --config-file ../../shared/backup/config.rb;
    echo "=================== Finish Backup Database =================";
  SHELL

  command command_string, output: 'log/crontab.log'
end

require 'rails'

job_type :shell_with_env, <<-SHELL
  export PATH="$HOME/.rbenv/bin:$PATH" &&
  eval "$(rbenv init -)" &&
  cd :path &&
  source .env &&
  bin/rails runner -e :environment ":task" :output"
SHELL

job_type :rake_with_env , <<-SHELL
  export PATH="$HOME/.rbenv/bin:$PATH" &&
  eval "$(rbenv init -)" &&
  source ~/.bashrc &&
  cd :path &&
  source .env &&
  :environment_variable=:environment bin/rake :task --silent :output
SHELL

every :hour do
  rake_with_env 'schedule:mail_hourly', output: 'log/crontab.log'
end

every :day do
  rake_with_env 'schedule:delete_user_daily', output: 'log/crontab.log'
end

time = ActiveSupport::TimeZone['Asia/Shanghai'].parse('03:00').utc
every :day, at: time.strftime('%H:%M') do
  command_string = <<-SHELL
    export PATH="$HOME/.rbenv/bin:$PATH" &&
    eval "$(rbenv init -)" &&
    echo "=================== Start Backup Database ==================" &&
    hash backup && backup perform -t backup_db --config-file ../../shared/backup/config.rb &&
    echo "=================== Finish Backup Database ================="
  SHELL

  command command_string, output: 'log/crontab.log'
end

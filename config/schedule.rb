require 'rails'

preparation = <<-SHELL
  export PATH="$HOME/.rbenv/bin:$PATH" &&
  export RBENV_ROOT=~/.rbenv &&
  export RBENV_VERSION=#{RUBY_VERSION} &&
  eval "$(rbenv init -)" &&
  cd :path
SHELL

job_type :shell_with_env, "#{preparation} && :task :output"
job_type :rake_with_env , "#{preparation} && :environment_variable=:environment bin/rake :task --silent :output"

every :hour do
  rake_with_env 'schedule:mail_hourly', output: 'log/crontab.log'
end

every :day do
  rake_with_env 'schedule:delete_user_daily', output: 'log/crontab.log'
end

time = ActiveSupport::TimeZone['Asia/Shanghai'].parse('03:00').utc
every :day, at: time.strftime('%H:%M') do
  command_string = <<-SHELL
    ~/.rbenv/bin/rbenv exec backup version && {
      echo "=================== Start Backup Database ==================";
       ~/.rbenv/bin/rbenv exec backup perform -t backup_db --config-file ../../shared/backup/config.rb;
      echo "=================== Finish Backup Database =================";
    }
  SHELL

  shell_with_env command_string, output: 'log/crontab.log'
end

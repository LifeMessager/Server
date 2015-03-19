Raven.configure do |raven_config|
  dsn = Settings.sentry_dsn
  raven_config.dsn = dsn if dsn
end

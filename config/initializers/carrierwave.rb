CarrierWave.configure do |config|
  if Rails.env.test? or Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :upyun
    config.upyun_username = Settings.upyun_username
    config.upyun_password = Settings.upyun_password
    config.upyun_bucket = Settings.upyun_bucket
    config.upyun_bucket_host = Settings.upyun_bucket_host
  end
end

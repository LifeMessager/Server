class Settings < Settingslogic
  source "#{Rails.root}/config/lifemessager.yml"
  namespace Rails.env
  load! if Rails.env.development?

  def mailer_deliverer_full_address
    "#{mailer_deliverer}@#{server_name}"
  end

  def mailer_deliver_from
    "#{mailer_nickname} <#{mailer_deliverer_full_address}>"
  end
end

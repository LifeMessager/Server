class WebUrl
  def login **params
    "#{prefix}/sessions/new?#{params.to_query}"
  end

  def change_email **params
    "#{prefix}/user/email/edit?#{params.to_query}"
  end

  private

  def url_protocol
    Rails.env.production? ? 'https' : 'http'
  end

  def prefix
    "#{url_protocol}://#{Settings.server_name}/#!"
  end
end

class Settings < Settingslogic
  source "#{Rails.root}/config/lifemessager.yml"
  namespace Rails.env
  load! if Rails.env.development?

  def initialize
    @web_url = WebUrl.new
    super
  end

  def url_protocol
    @web_url.send :url_protocol
  end

  def web_url_for type, **params
    @web_url.public_send type.to_sym, **params
  end

  def mailer_deliverer_full_address
    "#{mailer_deliverer}@#{server_name}"
  end

  def mailer_deliver_from
    "#{mailer_nickname} <#{mailer_deliverer_full_address}>"
  end
end

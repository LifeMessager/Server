class UserMailer < ActionMailer::Base
  def welcome user
    @token = Token.new user: user
    mail_receiver = MailReceiver.for user
    headers = {
      reply_to: beauty_reply_to(mail_receiver),
      :'List-Unsubscribe' => user.unsubscribe_email_header
    }
    mail fill_default_headers(headers, user)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.login.subject
  #
  def login user
    @token = Token.new user: user
    mail fill_default_headers(nil, user)
  end

  def destroyed user
    @user = user
    @token = Token.new user: user
    attachments['exported_data.json'] = {
      mime_type: 'application/json',
      content: user.export_data.to_json
    }
    mail fill_default_headers(nil, user)
  end

  def change_email user, email
    @user = user
    @change_email_url = user.change_email_url email
    mail fill_default_headers({to: email}, user)
  end

  private

  def fill_default_headers headers, user
    default_headers = {
      from: Settings.mailer_deliver_from,
      to: user.email
    }

    default_headers.merge headers || {}
  end
end

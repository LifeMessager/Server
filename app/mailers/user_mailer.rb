class UserMailer < ActionMailer::Base
  def welcome user
    @token = Token.new user: user
    mail_receiver = MailReceiver.create user: user
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

  private

  def fill_default_headers headers, user
    default_headers = {
      from: beauty_sender,
      to: user.email
    }

    default_headers.merge headers || {}
  end
end

class UserMailer < ActionMailer::Base
  def welcome user
    @token = Token.new user: user
    mail_receiver = MailReceiver.create user: user
    headers = {
      reply_to: "#{mail_receiver.address}@#{mailer_info[:domain]}",
      subject: I18n.t('user_mailer.welcome.subject'),
      :'List-Unsubscribe' => "<http://#{mailer_info[:domain]}#{user.unsubscribe_path}>"
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
    mail fill_default_headers({subject: I18n.t('user_mailer.login.subject')}, user)
  end

  private

  def fill_default_headers headers, user
    default_headers = {
      from: "#{mailer_info[:nickname]} <#{mailer_info[:deliverer]}@#{mailer_info[:domain]}>",
      to: user.email
    }

    default_headers.merge headers
  end
end

class DiaryMailer < ActionMailer::Base
  def welcome user
    send_mail_to user, subject: I18n.t('mail.welcome.title')
  end

  def daily user
    @diary_notes = (user.random_diary or [])
    @user = user
    send_mail_to user, subject: I18n.t('mail.daily.title', date: I18n.l(Time.now, format: :mail_title))
  end

  private

  def mailer_info
    Rails.application.config.mailer_info
  end

  def send_mail_to user, headers = {}, &block
    mail_receiver = MailReceiver.create user: user

    headers 'List-Unsubscribe' => "<http://#{mailer_info[:domain]}#{user.unsubscribe_path}>"
    mailgun_compatibly mail fill_default_headers(headers, mail_receiver), &block
  end

  HANDLED_HEADERS = %w{from to subject reply-to mime-version content-type}
  def mailgun_compatibly email
    custom_headers = email.header.fields
                     .reject { |field| HANDLED_HEADERS.include? field.name.to_s.downcase }
                     .map { |field| [field.name, field.value] }
                     .to_h
    email.mailgun_headers = custom_headers
    email
  end

  def fill_default_headers headers, mail_receiver
    default_headers = {
      from: "#{mailer_info[:nickname]} <#{mailer_info[:deliverer]}@#{mailer_info[:domain]}>",
      reply_to: "#{mail_receiver.address}@#{mailer_info[:domain]}",
      to: mail_receiver.user.email
    }

    default_headers.merge headers
  end
end

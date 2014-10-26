class DiaryMailer < ActionMailer::Base
  def daily user
    @diary_notes = (user.random_diary or [])
    @user = user
    send_mail_to user, subject: I18n.t('diary_mailer.daily.subject', date: I18n.l(Time.now, format: :mail_title))
  end

  private

  def send_mail_to user, headers = {}, &block
    mail_receiver = MailReceiver.create user: user

    headers 'List-Unsubscribe' => "<http://#{mailer_info[:domain]}#{user.unsubscribe_path}>"
    mail fill_default_headers(headers, mail_receiver), &block
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

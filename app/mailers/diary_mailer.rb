class DiaryMailer < ActionMailer::Base
  def daily user
    random_diary = user.random_diary
    @diary_notes = random_diary ? random_diary.notes : []
    @user = user
    @token = Token.new user: user
    send_mail_to user, subject: I18n.t('diary_mailer.daily.subject', date: I18n.l(Time.now, format: :mail_title))
  end

  private

  def send_mail_to user, headers = {}, &block
    mail_receiver = MailReceiver.for user
    headers['List-Unsubscribe'] = user.unsubscribe_email_header
    mail fill_default_headers(headers, mail_receiver), &block
  end

  def fill_default_headers headers, mail_receiver
    default_headers = {
      from: beauty_sender,
      reply_to: beauty_reply_to(mail_receiver),
      to: mail_receiver.user.email
    }

    default_headers.merge headers
  end
end

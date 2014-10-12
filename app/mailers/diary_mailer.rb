class DiaryMailer < ActionMailer::Base
  def welcome(user)
    (mail_receiver = MailReceiver.new user: user).save
    mail(
      from: "#{mailer_info[:nickname]} <#{mailer_info[:deliverer]}@#{mailer_info[:domain]}>",
      reply_to: "#{mail_receiver.address}@#{mailer_info[:domain]}",
      to: user.email,
      subject: I18n.t('mail.welcome.title')
    )
  end

  def daily(user)
    @diary_notes = (user.random_diary or [])
    @user = user
    (mail_receiver = MailReceiver.new user: user).save
    mail(
      from: "#{mailer_info[:nickname]} <#{mailer_info[:deliverer]}@#{mailer_info[:domain]}>",
      reply_to: "#{mail_receiver.address}@#{mailer_info[:domain]}",
      to: user.email,
      subject: I18n.t('mail.daily.title', date: I18n.l(Time.now, format: :mail_title))
    )
  end

  private

  def mailer_info
    Rails.application.config.mailer_info
  end
end

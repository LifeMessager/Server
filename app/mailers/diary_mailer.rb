class DiaryMailer < ActionMailer::Base
  def welcome(user)
    (ms = MailSender.new receiver: user.email).save
    mail from: "Diary <#{ms.address}@mailgun.plafer.info>", to: user.email, subject: I18n.t('mail.welcome.title')
  end

  def daily(user)
    @diary_notes = user.random_diary or []
    @user = user
    (ms = MailSender.new receiver: user.email).save
    mail(
      from: "Diary <#{ms.address}@mailgun.plafer.info>",
      to: user.email,
      subject: I18n.t('mail.daily.title', date: I18n.l(Time.now, format: :mail_title))
    )
  end
end

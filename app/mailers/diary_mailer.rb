class DiaryMailer < ActionMailer::Base
  def welcome(user)
    (ms = MailSender.new receiver: user.email).save
    mail from: "Diary <#{ms.address}@mailgun.plafer.info>", to: user.email, subject: '感谢使用日记服务'
  end
end

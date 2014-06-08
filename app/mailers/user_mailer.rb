class UserMailer < ActionMailer::Base

  def welcome(user)
    mail from: 'Diary <welcome@mailgun.plafer.info>', to: user.email, subject: '感谢使用日记服务'
  end
end

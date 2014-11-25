class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome User.all.sample
  end

  def login
    UserMailer.login User.all.sample
  end
end

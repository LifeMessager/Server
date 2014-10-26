class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome User.find_or_create_by email: 'hello@world.com'
  end

  def login
    UserMailer.login User.find_or_create_by email: 'hello@world.com'
  end
end

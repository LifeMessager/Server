class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome User.new(
      email: 'hello@world.com'
    )
  end
end

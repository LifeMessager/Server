class DiaryMailerPreview < ActionMailer::Preview
  def welcome
    DiaryMailer.welcome User.new(
      email: 'hello@world.com'
    )
  end
end

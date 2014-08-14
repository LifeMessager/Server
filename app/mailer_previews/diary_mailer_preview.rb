class DiaryMailerPreview < ActionMailer::Preview
  def welcome
    DiaryMailer.welcome User.new(
      email: 'hello@world.com'
    )
  end

  def daily
    DiaryMailer.daily User.all.sort{ |user1, user2|
      user1.diaries.size > user2.diaries.size ? -1 : 1
    }.first
  end
end

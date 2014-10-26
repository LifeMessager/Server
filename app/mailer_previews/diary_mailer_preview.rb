class DiaryMailerPreview < ActionMailer::Preview
  def daily
    DiaryMailer.daily User.all.sort{ |user1, user2|
      user1.notes.size > user2.notes.size ? -1 : 1
    }.first
  end
end

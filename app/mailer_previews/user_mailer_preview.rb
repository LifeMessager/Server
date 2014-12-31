class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome user
  end

  def login
    UserMailer.login user
  end

  def destroyed
    user.deleted_at = Time.now
    UserMailer.destroyed user
  end

  private

  def user
    @user ||= User.all.sample
  end
end

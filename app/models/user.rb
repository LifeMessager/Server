# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  before_save { self.email = self.email.downcase }

  has_many :diaries

  def random_diary
    return if self.diaries.length == 0
    random_note_date = self.diaries.map(&:note_date).uniq.sample
    self.diaries.where note_date: random_note_date
  end
end

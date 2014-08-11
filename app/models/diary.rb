# == Schema Information
#
# Table name: diaries
#
#  id         :integer          not null, primary key
#  from_email :string(255)      not null
#  content    :text             not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Diary < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :from_email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :content   , presence: true
  validates :user_id   , presence: true

  belongs_to :user

  def create_date(time_zone = Time.zone.now.zone)
    created_at.in_time_zone(time_zone).to_date
  end
end

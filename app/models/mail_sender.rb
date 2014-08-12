# == Schema Information
#
# Table name: mail_senders
#
#  id         :integer          not null, primary key
#  address    :string(255)      not null
#  receiver   :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

require 'securerandom'

class MailSender < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :address , presence: true
  validates :receiver, presence: true, format: { with: VALID_EMAIL_REGEX }

  after_initialize do
    self.address ||= "post+#{SecureRandom.hex}"
  end

  def note_date(time_zone = Time.zone.now.zone)
    created_at.in_time_zone(time_zone).to_date
  end
end

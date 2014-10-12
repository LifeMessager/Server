# == Schema Information
#
# Table name: mail_receivers
#
#  id         :integer          not null, primary key
#  address    :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#

require 'securerandom'

class MailReceiver < ActiveRecord::Base
  validates :address, presence: true
  validates :user   , presence: true

  belongs_to :user
  has_many :notes

  after_initialize do
    self.address ||= "post+#{SecureRandom.hex}"
  end

  def note_date(time_zone = Time.zone.now.zone)
    created_at.in_time_zone(time_zone).to_date
  end
end

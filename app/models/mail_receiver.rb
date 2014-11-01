# == Schema Information
#
# Table name: mail_receivers
#
#  id         :integer          not null, primary key
#  address    :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#  timezone   :string(255)      not null
#

require 'securerandom'

class MailReceiver < ActiveRecord::Base
  validates :address  , presence: true
  validates :user     , presence: true
  validates :timezone , presence: true

  belongs_to :user
  has_many :notes

  readonly_attributes :address, :timezone

  after_initialize do
    self.address = "post+#{SecureRandom.hex}" unless address
    self.timezone = user.timezone if not timezone and user
  end

  def note_date
    created_at.in_time_zone(timezone).to_date
  end

  def user= user
    if user.class == User
      write_attribute :user_id, user.id
      self.timezone = user.timezone
    else
      write_attribute :user_id, nil
      self.timezone = nil
    end
  end
end

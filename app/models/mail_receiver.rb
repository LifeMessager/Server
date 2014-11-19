# == Schema Information
#
# Table name: mail_receivers
#
#  id              :integer          not null, primary key
#  address         :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer          not null
#  timezone        :string(255)      not null
#  local_note_date :date             not null
#

require 'securerandom'

class MailReceiver < ActiveRecord::Base
  validates :address         , presence: true
  validates :user            , presence: true
  validates :timezone        , presence: true
  validates :local_note_date , presence: true

  belongs_to :user
  has_many :notes

  readonly_attributes :address, :timezone

  after_initialize do
    self.address = SecureRandom.hex unless address
    self.timezone = user.timezone if not timezone and user
    refresh_note_date if local_note_date.nil?
  end

  def full_address
    mailer_info = Rails.application.config.mailer_info
    "post+#{address}@#{mailer_info[:domain]}"
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

  private

  def refresh_note_date
    self.local_note_date = Time.now.in_time_zone(timezone).to_date
  end
end

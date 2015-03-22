# == Schema Information
#
# Table name: notes
#
#  id               :integer          not null, primary key
#  from_email       :string(255)      not null
#  content          :text             not null
#  created_at       :datetime
#  updated_at       :datetime
#  mail_receiver_id :integer          not null
#  type             :string(255)
#

class Note < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :from_email   , presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :content      , presence: true
  validates :mail_receiver, presence: true

  belongs_to :mail_receiver, counter_cache: true

  def local_note_date
    mail_receiver.local_note_date
  end

  def user
    mail_receiver.user
  end
end

class ImageNote < Note
  mount_uploader :content, ImageUploader
  validate :validation_content_size

  LARGEST_SIZE = 2.megabytes

  private

  def validation_content_size
    return unless content
    errors[:content] << 'invalid' if content.size > LARGEST_SIZE
  end
end

class TextNote < Note
end

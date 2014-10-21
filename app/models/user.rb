# coding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  email             :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  subscribed        :boolean          default(TRUE)
#  unsubscribe_token :string(255)      not null
#

require 'securerandom'

class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  has_many :mail_receivers
  has_many :notes, through: :mail_receivers

  readonly_attributes :subscribed, :unsubscribe_token

  before_save { self.email = self.email.downcase }

  # ActiveRecord 在实例化 User 的时候，subscribed 是有默认值的，但此时
  # unsubscribe_token 还是空的，所以需要额外检查一下
  after_initialize { generate_unsubscribe_token if unsubscribe_token.nil? }

  def random_diary
    return if notes.empty?
    mail_receivers.sample.notes
  end

  def subscribe
    return if subscribed
    self.subscribed = true
    generate_unsubscribe_token
  end

  def unsubscribe **options
    valid = options[:token] == unsubscribe_token
    return false unless valid
    return unless subscribed
    self.subscribed = false
    true
  end

  private

  def generate_unsubscribe_token
    self.unsubscribe_token = SecureRandom.hex
  end
end

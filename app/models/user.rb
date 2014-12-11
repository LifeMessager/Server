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
#  timezone          :string(255)      not null
#  alert_time        :datetime         not null
#  language          :string(255)      not null
#

require 'securerandom'

TimeZone = ActiveSupport::TimeZone

class User < ActiveRecord::Base
  VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  ALERT_PLACEHOLDER_DAY = '2014-01-01'

  def self.timezones
    TimeZone.zones_map.values.map{ |zone| zone.tzinfo.name }.uniq
  end

  def self.languages
    ['zh-Hans-CN', 'zh-Hant-TW', 'en']
  end

  validates :email,      presence: true, format: { with: VALID_EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :timezone,   presence: true, inclusion: { in: timezones }
  validates :language,   presence: true, inclusion: { in: languages }
  validates :alert_time, presence: true

  has_many :mail_receivers
  has_many :notes, through: :mail_receivers

  readonly_attributes :subscribed, :unsubscribe_token

  before_save { self.email = email.downcase }

  # ActiveRecord 在实例化 User 的时候，subscribed 是有默认值的，但此时
  # unsubscribe_token 还是空的，所以需要额外检查一下
  after_initialize { generate_unsubscribe_token if unsubscribe_token.nil? }

  # WARNING: 只接受本地时间
  scope :alertable, -> (time = Time.now) do
    formatted_time = time.strftime '%H:%M'
    # 只有 Time 转化的时间是使用当前服务器时区的
    query_time = Time.parse "#{User::ALERT_PLACEHOLDER_DAY} #{formatted_time}"
    start_time = query_time.beginning_of_hour
    end_time = query_time.end_of_hour
    order(:alert_time).where('? <= alert_time AND alert_time < ? AND email_verified = true', start_time, end_time)
  end

  def random_diary
    return if notes.empty?
    mail_receivers.sample.notes
  end

  def unsubscribe_link
    return if new_record?
    host_domain = Rails.application.config.mailer_info[:domain]
    # http://api.rubyonrails.org/classes/ActionDispatch/Routing/UrlFor.html
    # http://stackoverflow.com/questions/341143/can-rails-routing-helpers-i-e-mymodel-pathmodel-be-used-in-models
    path = Rails.application.routes.url_helpers.user_subscription_path(
      _method: :delete,
      token: "unsubscribe #{unsubscribe_token}",
      user_id: id,
      action: :unsubscribe
    )
    "#{host_domain}#{path}"
  end

  def unsubscribe_email_address
    return if new_record?
    host_domain = Rails.application.config.mailer_info[:domain]
    "unsubscribe+#{unsubscribe_token}@#{host_domain}"
  end

  def unsubscribe_email_header
    return if new_record?
    "<mailto:#{unsubscribe_email_address}>, <http://#{unsubscribe_link}>"
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

  def tz
    ActiveSupport::TimeZone.new timezone
  end

  def timezone= input_timezone
    if input_timezone.class == ActiveSupport::TimeZone
      input_timezone = input_timezone.identifier
    end
    unless User.timezones.include? input_timezone
      input_timezone = nil
    end
    self.alert_time = nil if input_timezone.nil?
    write_attribute :timezone, input_timezone
  end

  def alert_time
    return unless alert_datetime = read_attribute(:alert_time)
    alert_datetime.in_time_zone(timezone).to_s :time
  end

  def alert_time= time
    return unless timezone
    formatted_time = "#{User::ALERT_PLACEHOLDER_DAY} #{time}#{tz.formatted_offset}"
    acceptable = tz.parse formatted_time if time
    write_attribute :alert_time, acceptable
  end

  private

  def generate_unsubscribe_token
    self.unsubscribe_token = SecureRandom.hex
  end
end

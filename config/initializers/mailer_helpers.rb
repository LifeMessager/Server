module MailerHelper
  extend ActiveSupport::Concern

  private

  def mailer_info
    Rails.application.config.mailer_info
  end

  def host_domain
    mailer_info[:domain]
  end

  def display_sender
    "#{mailer_info[:nickname]} <#{mailer_info[:deliverer]}@#{host_domain}>"
  end

  module ClassMethods
  end
end

# include the extension
ActionMailer::Base.send :include, MailerHelper

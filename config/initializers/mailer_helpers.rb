module MailerHelper
  extend ActiveSupport::Concern

  private

  def beauty_reply_to mail_receiver
    "#{Settings.mailer_nickname} <#{mail_receiver.full_address}>"
  end

  module ClassMethods
  end
end

# include the extension
ActionMailer::Base.send :include, MailerHelper

module MailgunCompatiblyExtension
  extend ActiveSupport::Concern

  private

  HANDLED_HEADERS = %w{from to subject reply-to mime-version content-type}
  def mail_with_mailgun_compatibly headers = {}, &block
    email = mail_without_mailgun_compatibly headers, &block
    custom_headers = email.header.fields
                     .reject { |field| HANDLED_HEADERS.include? field.name.to_s.downcase }
                     .map { |field| [field.name, field.value] }
                     .to_h
    email.mailgun_headers = custom_headers
    email
  end

  def self.included base
    base.class_eval do
      alias_method :mail_without_mailgun_compatibly, :mail
      alias_method :mail, :mail_with_mailgun_compatibly
    end
  end

  module ClassMethods
  end
end

# include the extension
ActionMailer::Base.send :include, MailgunCompatiblyExtension

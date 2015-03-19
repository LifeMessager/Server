# coding: utf-8
class MailsController < ApplicationController
  skip_before_action :verify_token
  skip_before_action :verify_timezone_header
  before_action :check_recipient
  before_action :verify_user_email

  def notes
    unless mail_receiver
      error_log 'notes', "target mail_receiver not exist (#{recipient[:id]})"
      return simple_respond nil, status: :ok
    end

    note = mail_receiver.notes.build(
      from_email: params['sender'],
      content: params['stripped-text'],
      mail_receiver: mail_receiver,
      created_at: params['Date']
    )

    if note.invalid?
      error_log 'notes', "note info not valid: #{note.errors}"
      return simple_respond nil, status: :ok
    end

    if note.save
      simple_respond nil, status: :created
    else
      error_log 'notes', "note save failed: #{note.errors}"
      simple_respond nil, status: :internal_server_error
    end
  end

  def unsubscriptions
    unsubscribe_token = recipient[:id]

    unless email_user
      error_log 'unsubscriptions', "target user not exist (#{params['sender']})"
      return simple_respond nil, status: :ok
    end

    unless email_user.unsubscribe token: unsubscribe_token
      error_log 'unsubscriptions', "unsubscribe_token not valid (#{unsubscribe_token})"
      return simple_respond nil, status: :ok
    end

    if email_user.save
      simple_respond nil, status: :created
    else
      error_log 'unsubscriptions', "unsubscription save failed: #{user.errors}"
      simple_respond nil, status: :internal_server_error
    end
  end

  private

  def error_log method_name, content
    Rails.logger.error "[MailsController##{method_name}] #{content}"
  end

  def recipient_mail_id
    return unless recipient = params['recipient']
    @recipient_mail_id ||= recipient[/^([^@]+).*$/, 1]
  end

  def recipient_is_deliverer
    recipient_mail_id == Settings.mailer_deliverer
  end

  def check_recipient
    unless recipient_is_deliverer or recipient[:id]
      error_log "check_recipient", "recipient invalid"
      return simple_respond nil, status: :ok
    end
  end

  def verify_user_email
    if user = mail_receiver ? mail_receiver.user : email_user
      user.email_verified = true
      unless user.save
        message = "save user.email_verified failed, #{user.errors.full_messages}"
        error_log 'verify_user_email', message
      end
    end
  end

  def recipient
    type, id = recipient_mail_id.split '+', 2
    {type: type, id: id}
  end

  def email_user
    @email_user ||= User.find_by_email params['sender']
  end

  def mail_receiver
    return @mail_receiver if @mail_receiver
    if recipient_is_deliverer
      return unless email_user
      @mail_receiver = MailReceiver.for email_user
    else
      @mail_receiver = MailReceiver.find_by_address recipient[:id]
    end
    @mail_receiver
  end
end

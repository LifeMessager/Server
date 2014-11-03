class MailsController < ApplicationController
  skip_before_action :verify_token
  before_action :check_recipient

  def notes
    mail_receiver = MailReceiver.find_by_address recipient[:id]

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
    user = User.find_by_email params['sender']
    unsubscribe_token = recipient[:id]

    unless user
      error_log 'unsubscriptions', "target user not exist (#{params['sender']})"
      return simple_respond nil, status: :ok
    end

    unless user.unsubscribe token: unsubscribe_token
      error_log 'unsubscriptions', "unsubscribe_token not valid (#{unsubscribe_token})"
      return simple_respond nil, status: :ok
    end

    if user.save
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

  def recipient
    return unless recipient = params['recipient']
    return unless address = recipient[/^([^@]+).*$/, 1]
    type, id = address.split '+', 2
    {type: type, id: id}
  end

  def check_recipient
    unless recipient[:id]
      Rails.logger.error "[MailsController] recipient invalid"
      return simple_respond nil, status: :ok
    end
  end
end

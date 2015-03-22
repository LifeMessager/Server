# coding: utf-8

class MailsController < ApplicationController
  skip_before_action :verify_token
  skip_before_action :verify_timezone_header
  before_action :check_recipient
  before_action :verify_user_email

  def notes
    unless mail_receiver
      error_log "target mail_receiver not exist (#{recipient[:id]})"
      return simple_respond nil, status: :ok
    end

    notes = build_notes(mail_receiver).select do |note|
      next note if note.valid?
      error_log "note info not valid: #{note.errors.as_json}"
      false
     end

    return simple_respond nil, status: :ok if notes.empty?

    begin
      Note.transaction do
        notes.each do |note|
          raise "note save failed: #{note.errors.as_json}" unless note.save
        end
      end
      simple_respond nil, status: :created
    rescue Exception => ex
      error_log ex.message
      simple_respond nil, status: :internal_server_error
    end
  end

  def unsubscriptions
    unsubscribe_token = recipient[:id]

    unless email_user
      error_log "target user not exist (#{params['sender']})"
      return simple_respond nil, status: :ok
    end

    unless email_user.unsubscribe token: unsubscribe_token
      error_log "unsubscribe_token not valid (#{unsubscribe_token})"
      return simple_respond nil, status: :ok
    end

    if email_user.save
      simple_respond nil, status: :created
    else
      error_log "unsubscription save failed: #{user.errors}"
      simple_respond nil, status: :internal_server_error
    end
  end

  private

  def error_log content
    method_name = caller_locations(1, 1).first.label
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
      error_log "recipient invalid"
      return simple_respond nil, status: :ok
    end
  end

  def verify_user_email
    if user = mail_receiver ? mail_receiver.user : email_user
      user.email_verified = true
      unless user.save
        error_log "save user.email_verified failed, #{user.errors.as_json}"
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

  def build_notes mail_receiver
    notes = []

    stripped_text = params['stripped-text']
    if stripped_text && !stripped_text.chomp.empty?
      notes << mail_receiver.notes.build(
        from_email: params['sender'],
        created_at: params['Date'],
        content: stripped_text
      ).becomes!(TextNote)
    end

    params['attachment-count'].to_i.times do |index|
      note = mail_receiver.notes.build(
        from_email: params['sender'],
        created_at: params['Date']
      ).becomes!(ImageNote)

      # 不能直接把 UploadedFile 作为 #build 的参数, 因为那个时候实例还不是 ImageNote
      # carrierwave 定义的 #content= 不会生效, 导致 #content 的值会出问题 , @file 会
      # 变成 /.../public/image_note/content/#<File:0x007fbcab438ef0>
      note.content = params["attachment-#{index + 1}"]

      notes << note
    end

    notes
  end
end

class DiaryMailer < ActionMailer::Base
  helper_method :note_content_to_html, :note_content_to_text

  def daily user
    random_diary = user.random_diary
    @diary_notes = random_diary ? random_diary.notes : []
    @user = user
    @token = Token.new user: user
    send_mail_to user, subject: I18n.t('diary_mailer.daily.subject', date: I18n.l(Time.now, format: :mail_title))
  end

  private

  def note_content_to_html content
    p_tag_style="margin: 5px 0"
    inner_html = NoteHelper.clean_content(content).split(/\n\n/).join("</p><p style='#{p_tag_style}'>")
    "<p style='#{p_tag_style}'>#{inner_html}</p>"
  end

  def note_content_to_text content
    NoteHelper.clean_content content
  end

  def send_mail_to user, headers = {}, &block
    mail_receiver = MailReceiver.for user
    headers['List-Unsubscribe'] = user.unsubscribe_email_header
    mail fill_default_headers(headers, mail_receiver), &block
  end

  def fill_default_headers headers, mail_receiver
    default_headers = {
      from: Settings.mailer_deliver_from,
      reply_to: beauty_reply_to(mail_receiver),
      to: mail_receiver.user.email
    }

    default_headers.merge headers
  end
end

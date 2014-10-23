require "rails_helper"

mail_info = Rails.application.config.mailer_info

describe DiaryMailer do
  describe '.welcome' do
    it 'send a welcome email to user' do
      user = create :user
      mail = DiaryMailer.welcome user
      expect(mail).to have_subject 'mail.welcome.title'
      expect(mail).to reply_to "#{user.mail_receivers.first.address}@#{mail_info[:domain]}"
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from "#{mail_info[:nickname]} <#{mail_info[:deliverer]}@#{mail_info[:domain]}>"
      expect(mail).to have_header 'List-Unsubscribe', "<http://#{mail_info[:domain]}#{user.unsubscribe_path}>"
      expect(mail.mailgun_headers).to eq 'List-Unsubscribe' => "<http://#{mail_info[:domain]}#{user.unsubscribe_path}>"
    end
  end

  describe '.daily' do
    it 'send a daily email to user' do
      user = create :user
      mail = DiaryMailer.daily user
      expect(mail).to have_subject 'mail.daily.title'
      expect(mail).to reply_to "#{user.mail_receivers.first.address}@#{mail_info[:domain]}"
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from "#{mail_info[:nickname]} <#{mail_info[:deliverer]}@#{mail_info[:domain]}>"
      expect(mail).to have_header 'List-Unsubscribe', "<http://#{mail_info[:domain]}#{user.unsubscribe_path}>"
      expect(mail.mailgun_headers).to eq 'List-Unsubscribe' => "<http://#{mail_info[:domain]}#{user.unsubscribe_path}>"
    end
  end
end

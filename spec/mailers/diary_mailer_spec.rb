require "rails_helper"

describe DiaryMailer, :type => :mailer do
  describe '.daily' do
    let(:user) { create :user }

    let(:mail) { DiaryMailer.daily user }

    it 'send a daily email to user' do
      expect(mail).to have_subject 'diary_mailer.daily.subject'
      expect(mail).to reply_to "#{Settings.mailer_nickname} <#{user.mail_receivers.first.full_address}>"
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from Settings.mailer_deliver_from
      expect(mail).to have_header 'List-Unsubscribe', user.unsubscribe_email_header
      expect(mail.mailgun_headers).to eq 'List-Unsubscribe' => user.unsubscribe_email_header
    end
  end
end

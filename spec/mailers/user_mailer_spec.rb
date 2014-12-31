require "rails_helper"

mail_info = Rails.application.config.mailer_info

RSpec.describe UserMailer, :type => :mailer do
  describe '.welcome' do
    let(:user) { create :user }

    let(:mail) { UserMailer.welcome user }

    it 'send a welcome email to user' do
      expect(mail).to have_subject 'subject'
      expect(mail).to reply_to "#{mail_info[:nickname]} <#{user.mail_receivers.first.full_address}>"
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from "#{mail_info[:nickname]} <#{mail_info[:deliverer]}@#{mail_info[:domain]}>"
      expect(mail).to have_header 'List-Unsubscribe', user.unsubscribe_email_header
      expect(mail.mailgun_headers).to eq 'List-Unsubscribe' => user.unsubscribe_email_header
    end
  end

  describe ".login" do
    let(:user) { create :user }

    let(:mail) { UserMailer.login user }

    it "renders the headers" do
      expect(mail).to have_subject 'subject'
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from "#{mail_info[:nickname]} <#{mail_info[:deliverer]}@#{mail_info[:domain]}>"
    end
  end

  describe ".destoryed" do
    let(:user) { create :user, deleted_at: Time.now }

    let(:mail) { UserMailer.destroyed user }

    it "renders the headers" do
      expect(mail).to have_subject 'subject'
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from "#{mail_info[:nickname]} <#{mail_info[:deliverer]}@#{mail_info[:domain]}>"
    end
  end
end

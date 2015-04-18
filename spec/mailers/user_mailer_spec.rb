# coding: utf-8

require "rails_helper"

RSpec.describe UserMailer, :type => :mailer do
  describe '.welcome' do
    let(:user) { create :user }

    let(:mail) { UserMailer.welcome user }

    it 'send a welcome email to user' do
      expect(mail).to have_subject 'subject'
      expect(mail).to reply_to "#{Settings.mailer_nickname} <#{user.mail_receivers.first.full_address}>"
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from Settings.mailer_deliver_from
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
      expect(mail).to deliver_from Settings.mailer_deliver_from
    end
  end

  describe ".destoryed" do
    let(:user) { create :user, deleted_at: Time.now }

    let(:mail) { UserMailer.destroyed user }

    it "renders the headers" do
      expect(mail).to have_subject 'subject'
      expect(mail).to deliver_to user.email
      expect(mail).to deliver_from Settings.mailer_deliver_from
    end

    it "export data to user" do
      user.mail_receivers << create(:mail_receiver)
      # 好像只有 .create 会触发更新 notes_count ，如果是 .notes << create(:note) 的话就不会
      user.mail_receivers.first.notes.create content: 'hello world', from_email: user.email

      expect(mail.attachments.first.filename).to eq 'exported_data.json'
      expect(mail.attachments.first.read).to eq user.export_data.to_json
    end
  end

  describe '.change_email' do
    let(:user) { create :user }

    let(:mail) { UserMailer.change_email user, 'test@example.com' }

    it "renders the headers" do
      expect(mail).to have_subject 'subject'
      expect(mail).to deliver_to 'test@example.com'
      expect(mail).to deliver_from Settings.mailer_deliver_from
    end
  end
end

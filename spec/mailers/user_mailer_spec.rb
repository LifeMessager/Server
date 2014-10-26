require "rails_helper"

mail_info = Rails.application.config.mailer_info

RSpec.describe UserMailer, :type => :mailer do
  describe '.welcome' do
    let(:mail) do
      @user = create :user
      UserMailer.welcome @user
    end

    it 'send a welcome email to user' do
      expect(mail).to have_subject 'user_mailer.welcome.subject'
      expect(mail).to reply_to "#{@user.mail_receivers.first.address}@#{mail_info[:domain]}"
      expect(mail).to deliver_to @user.email
      expect(mail).to deliver_from "#{mail_info[:nickname]} <#{mail_info[:deliverer]}@#{mail_info[:domain]}>"
      expect(mail).to have_header 'List-Unsubscribe', "<http://#{mail_info[:domain]}#{@user.unsubscribe_path}>"
      expect(mail.mailgun_headers).to eq 'List-Unsubscribe' => "<http://#{mail_info[:domain]}#{@user.unsubscribe_path}>"
    end
  end

  describe ".login" do
    let(:mail) do
      @user = create :user
      UserMailer.login @user
    end

    it "renders the headers" do
      expect(mail).to have_subject 'user_mailer.login.subject'
      expect(mail).to deliver_to @user.email
      expect(mail).to deliver_from "#{mail_info[:nickname]} <#{mail_info[:deliverer]}@#{mail_info[:domain]}>"
    end
  end
end

# == Schema Information
#
# Table name: mail_receivers
#
#  id              :integer          not null, primary key
#  address         :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer          not null
#  timezone        :string(255)      not null
#  local_note_date :date             not null
#  notes_count     :integer          default(0)
#

require 'rails_helper'

mailer_info = Rails.application.config.mailer_info

describe MailReceiver do
  before { @mr = build :mail_receiver }

  subject { create :mail_receiver }

  it { is_expected.to respond_to :user }

  it { is_expected.to respond_to :notes }

  it { is_expected.to have_pattr_writer :address }
  its(:address) { is_expected.not_to be_nil }

  it { is_expected.to have_pattr_writer :timezone }
  its(:timezone) { is_expected.not_to be_nil }

  its(:full_address) { is_expected.to eq "post+#{subject.address}@#{mailer_info[:domain]}" }

  it 'is invalid without user' do
    @mr.user = nil
    expect(@mr).to be_invalid
    expect(@mr.errors[:user]).to include ModelError.BLANK
  end

  it "auto assign user's timezone" do
    originUser = @mr.user
    @mr.user = create :user, timezone: User.timezones[3]
    expect(@mr.timezone).to eq @mr.user.timezone
    expect(@mr.timezone).not_to eq originUser.timezone
  end

  describe '.for' do
    let(:user) { create :user }

    subject { MailReceiver }

    it { is_expected.to respond_to :for }

    context 'when the mail receiver for specified date not exist' do
      it 'will create a new record for now' do
        expect(user.mail_receivers).to be_empty
        newMailReceiver = MailReceiver.for user
        expect(newMailReceiver.local_note_date).to eq Time.now.in_time_zone(user.timezone).to_date
        expect(user.mail_receivers.count).to eq 1
        expect(user.mail_receivers.last).to eq newMailReceiver
      end

      it 'can specify date' do
        expect(user.mail_receivers).to be_empty
        newMailReceiver = MailReceiver.for user, date: Date.today - 1.day
        expect(newMailReceiver.local_note_date).to eq Date.today - 1.day
        expect(user.mail_receivers.count).to eq 1
        expect(user.mail_receivers.last).to eq newMailReceiver
      end
    end

    context 'when the mail receiver for specified date existed' do
      let(:mail_receiver) { create :mail_receiver }

      it 'will lookup the existed record' do
        result = MailReceiver.for mail_receiver.user
        expect(result).to eq mail_receiver
      end
    end
  end
end

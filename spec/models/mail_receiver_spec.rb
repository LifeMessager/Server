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

  it { is_expected.to have_readonly_attribute :address }
  its(:address) { is_expected.not_to be_nil }

  it { is_expected.to have_readonly_attribute :timezone }
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
end

# == Schema Information
#
# Table name: mail_receivers
#
#  id         :integer          not null, primary key
#  address    :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#

require 'rails_helper'

describe MailReceiver do
  before { @mr = build :mail_receiver }

  subject { @mr }

  it { is_expected.to respond_to :user }

  it { is_expected.to respond_to :notes }

  it { is_expected.to respond_to :address }

  it 'is valid with user' do
    expect(@mr.save).to be_truthy
  end

  it 'is invalid without user' do
    @mr.user = nil
    expect(@mr).to be_invalid
    expect(@mr.errors[:user]).to include ModelError.BLANK
  end

  it 'auto generate address' do
    expect(@mr.address).to be_a_kind_of String
  end
end

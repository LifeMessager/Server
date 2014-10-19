# == Schema Information
#
# Table name: notes
#
#  id               :integer          not null, primary key
#  from_email       :string(255)      not null
#  content          :text             not null
#  created_at       :datetime
#  updated_at       :datetime
#  mail_receiver_id :integer          not null
#

require 'rails_helper'

describe Note do
  before do
    @note = build :note
  end

  it { is_expected.to respond_to :content }

  it { is_expected.to respond_to :from_email }

  it { is_expected.to respond_to :mail_receiver }

  it 'is valid with `from_email`, `content`, `mail_receiver`' do
    expect(@note.save).to be_truthy
  end

  %w{from_email content mail_receiver}.each do |attribute|
    it "is invalid without `#{attribute}`" do
      @note.__send__ "#{attribute}=", nil
      expect(@note).to be_invalid
      expect(@note.errors[attribute.to_sym]).to include ModelError.BLANK
    end
  end
end

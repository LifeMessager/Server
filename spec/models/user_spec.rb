# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  email             :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  subscribed        :boolean          default(TRUE)
#  unsubscribe_token :string(255)      not null
#  timezone          :string(255)      not null
#  language          :string(255)      not null
#  email_verified    :boolean          default(FALSE), not null
#  alert_time        :string(255)      default("08:00"), not null
#  deleted_at        :datetime
#

require 'rails_helper'

describe User, type: :model do
  before { @user = build :user }

  subject { create :user }

  it { is_expected.to respond_to :notes }

  it { is_expected.to respond_to :mail_receivers }

  it { is_expected.to have_pattr_writer :subscribed }
  its(:subscribed) { is_expected.to be true }

  it { is_expected.to have_pattr_writer :unsubscribe_token }
  its(:unsubscribe_token) { is_expected.not_to be_nil }

  describe '.alertable' do
    def create_user alert_time
      user = build :user
      user.alert_time = alert_time.in_time_zone(user.timezone).strftime '%H:00'
      user.save!
      user
    end

    before(:all) do
      @user1 = create_user Time.now
      @user2 = create_user Time.now - 1.hour

      @unsubscribed_user1 = create_user Time.now
      @unsubscribed_user1.update_attribute :subscribed, false

      @unsubscribed_user2 = create_user Time.now - 1.hour
      @unsubscribed_user2.update_attribute :subscribed, false
    end

    context 'when alert time unspecified' do
      subject { User.alertable.pluck :id }
      it { is_expected.to include @user1.id }
      it { is_expected.not_to include @user2.id }
      it { is_expected.not_to include @unsubscribed_user1.id }
    end

    context 'when alert time specified' do
      subject { User.alertable(@user2.timezone.parse @user2.alert_time).pluck :id }
      it { is_expected.not_to include @user1.id }
      it { is_expected.to include @user2.id }
      it { is_expected.not_to include @unsubscribed_user2.id }
    end
  end

  describe '.really_destroyable' do
    before(:all) do
      @user1 = create :user
      @user2 = create :user

      @user1.update_attribute :deleted_at, Time.now
      @user2.update_attribute :deleted_at, Time.now - 8.days
    end

    subject { User.really_destroyable.pluck :id }

    it { is_expected.to include @user1.id }
    it { is_expected.not_to include @user2.id }
  end

  describe '.creatable?' do
    subject { User }
    after { Settings['user_limit'] = nil }

    context 'when user count do not limited' do
      before { Settings['user_limit'] = nil }
      it { is_expected.to be_creatable }
    end

    context 'when user count limited' do
      before { Settings['user_limit'] = User.count }
      it { is_expected.not_to be_creatable }
    end
  end

  describe '#email' do
    it { is_expected.to respond_to :email }

    its(:email) { is_expected.not_to be_nil }

    it 'is required' do
      @user.email = nil
      expect(@user).to be_invalid
      expect(@user.errors[:email]).to include ModelError.BLANK
    end

    it 'save address with downcase' do
      @user.email = 'HELLO@world.com'
      @user.save
      expect(@user.email).to eq @user.email.downcase
    end

    it 'work fine with valid format' do
      valid_addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      valid_addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user.save).to be true
      end
    end

    it 'is invalid with wrong format' do
      invalid_addresses = %w[user@foo,com user_at_foo.org example.user@foo.foo@bar_baz.com foo@barbaz]
      invalid_addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).to be_invalid
        expect(@user.errors[:email]).to include ModelError.INVALID
      end
    end

    it 'is invalid with a duplicate address' do
      @user.save
      newUser = build :user, email: @user.email
      expect(newUser).to be_invalid
      expect(newUser.errors[:email]).to include ModelError.TAKEN
    end
  end

  describe '#random_mail_receiver' do
    context 'when there are several notes' do
      it 'return a random diary' do
        @user.save

        10.times do |i|
          created_at = DateTime.now + i.day
          mr = create :mail_receiver, user: @user, created_at: created_at
          mr.notes << Note.new(
            from_email: @user.email,
            content: 'hello world',
            created_at: created_at
          )
        end

        def random_mail_receiver_id
          @user.random_mail_receiver.id
        end

        sample_result = 10.times.map { random_mail_receiver_id != random_mail_receiver_id }
                        .select { |is_different| is_different }
        expect(sample_result.length).to be > 5
      end
    end

    context 'when there are no note' do
      it 'return nil' do
        @user.save
        expect(@user.random_mail_receiver).to be_nil
      end
    end
  end

  describe '#subscribe' do
    context 'when user subscribed email' do
      it 'do nothing' do
        user = build :user
        unsubscribe_token = user.unsubscribe_token
        user.subscribe
        expect(user.unsubscribe_token).to eq unsubscribe_token
      end
    end

    context 'when user unsubscribed email' do
      it 'subscribe email and update unsubscribe token' do
        user = build :user
        unsubscribe_token = user.unsubscribe_token
        user.unsubscribe token: unsubscribe_token
        user.subscribe
        expect(user.unsubscribe_token).not_to eq unsubscribe_token
      end
    end
  end

  describe '#unsubscribe' do
    it 'unsubscribe email' do
      user = build :user
      expect(user.unsubscribe token: user.unsubscribe_token).to be true
      expect(user.subscribed).to be false
    end

    it 'need valid token' do
      user = build :user
      expect(user.unsubscribe).to be false
      expect(user.unsubscribe token: 'invalid token').to be false
    end
  end

  describe '#timezone' do
    its(:timezone) { is_expected.not_to be_nil }

    its(:timezone) { is_expected.to be_a_kind_of ActiveSupport::TimeZone }

    it 'is required' do
      @user.timezone = nil
      expect(@user).to be_invalid
      expect(@user.errors[:timezone]).to include ModelError.BLANK
    end

    it 'verify identifier acceptable' do
      @user.timezone = 'invalid timezone'
      expect(@user.timezone).to be_nil
    end

    it 'accept ActiveSupport::TimeZone instance' do
      instance = ActiveSupport::TimeZone.all.sample
      @user.timezone = instance
      expect(@user).to be_valid
      expect(@user.timezone.identifier).to eq instance.identifier
    end
  end

  describe '#alert_time' do
    it 'is required' do
      @user.alert_time = nil
      expect(@user).to be_invalid
      expect(@user.errors[:alert_time]).to include ModelError.BLANK
    end
  end

  describe '#unsubscribe_url' do
    it 'return nil if user is a new record' do
      expect(@user.unsubscribe_url).to be_nil
    end

    it 'generate unsubscribe link' do
      @user.save
      unsubscribe_path = Rails.application.routes.url_helpers.subscription_user_path(
        token: "unsubscribe #{@user.unsubscribe_token}",
        _method: :delete,
        id: @user.id,
        action: :unsubscribe
      )
      expect(@user.unsubscribe_url).to eq "http://#{Settings.server_name}#{unsubscribe_path}"
    end
  end

  describe '#unsubscribe_email_address' do
    it 'return nil if user is a new record' do
      expect(@user.unsubscribe_email_address).to be_nil
    end

    it 'generate unsubscribe email address' do
      @user.save
      expect(@user.unsubscribe_email_address).to eq "unsubscribe+#{@user.unsubscribe_token}@#{Settings.server_name}"
    end
  end

  describe '#unsubscribe_email_header' do
    it 'return nil if user is a new record' do
      expect(@user.unsubscribe_email_header).to be_nil
    end

    it 'generate unsubscribe email header' do
      @user.save
      expect(@user.unsubscribe_email_header).to eq "<mailto:#{@user.unsubscribe_email_address}>, <#{@user.unsubscribe_url}>"
    end
  end

  describe '#language' do
    it { is_expected.to respond_to :language }

    it 'is required' do
      @user.language = nil
      expect(@user).not_to be_valid
      expect(@user.errors.first).to include :language
    end

    it 'only accept language in User.languages' do
      @user.language = 'non-exist-language'
      expect(@user).not_to be_valid
      expect(@user.errors.first).to include :language
    end
  end

  describe '#really_destroy!' do
    let(:user) { create :user }

    it 'will destroy dependent mail receiver and notes' do
      mail_receiver = create :mail_receiver, user: user
      note = create :note, mail_receiver: mail_receiver
      expect(user.mail_receivers.count).to eq 1
      user.destroy
      expect(user.mail_receivers.count).to eq 1
      user.really_destroy!
      expect(MailReceiver.find_by_id mail_receiver.id).to be_nil
      expect(Note.find_by_id note.id).to be_nil
    end
  end

  describe '#change_email_token' do
    let(:user) { create :user }

    it 'return nil if user is a new record' do
      expect(@user.change_email_url 'test@example.com').to be_nil
    end

    it "generate token for change user's email address" do
      token = user.change_email_token 'test@example.com'
      decode_info = Token.decode token
      expect(decode_info).to include success: true
      expect(decode_info[:token]).to have_attributes user: user
      expect(decode_info[:token].data).to include 'email' => 'test@example.com'
    end
  end

  describe '#change_email' do
    let(:user) { create :user }

    it 'will change user email address' do
      token = user.change_email_token 'test@example.com'
      expect(user.change_email token).to be true
      expect(user.email).to eq 'test@example.com'
    end

    it 'return false with invalid token' do
      expect(user.change_email 'invalid_token').to be false
    end

    it "return false with other user's token" do
      other_user = create :user
      other_user_email_token = other_user.change_email_token 'test@example.com'
      expect(user.change_email other_user_email_token).to be false
    end
  end

  describe '#change_email_url' do
    it 'return nil if user is a new record' do
      expect(@user.change_email_url 'test@example.com').to be_nil
    end

    it 'generate change email url' do
      @user.save
      target_email = 'test@example.com'
      token = @user.change_email_token target_email
      expected_url = "http://#{Settings.server_name}/#!/user/email/edit?token=#{token}"
      expect(@user.change_email_url target_email).to eq expected_url
    end
  end
end

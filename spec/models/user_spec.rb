# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do
  before { @user = build :user }

  subject { @user }

  it { is_expected.to respond_to :email }

  it { is_expected.to respond_to :notes }

  it { is_expected.to respond_to :mail_receivers }

  it 'work fine with valid email address' do
    valid_addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      expect(@user.save).to be_truthy
    end
  end

  it 'report errors with invalid email address' do
    invalid_addresses = %w[user@foo,com user_at_foo.org example.user@foo.foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      expect(@user).to be_invalid
      expect(@user.errors[:email]).to include ModelError.INVALID
    end
  end

  it 'is invalid with a duplicate email address' do
    @user.save
    newUser = build :user, email: @user.email
    expect(newUser).to be_invalid
    expect(newUser.errors[:email]).to include ModelError.TAKEN
  end

  it 'save email with downcase' do
    @user.email = 'HELLO@world.com'
    @user.save
    expect(@user.email).to eq @user.email.downcase
  end

  describe '#random_diary' do
    context 'when there are several notes' do
      it 'return a random diary' do
        @user.save

        10.times do |i|
          created_at = DateTime.now + i.day
          mr = create :mail_receiver, user: @user, created_at: created_at
          create :note, {
            mail_receiver: mr,
            from_email: @user.email,
            content: 'hello world',
            created_at: created_at
          }
        end

        def random_diary_id
          @user.random_diary.first.id
        end

        sample_result = 10.times.map { random_diary_id != random_diary_id }
                        .select { |is_different| is_different }
        expect(sample_result.length).to be > 5
      end
    end

    context 'when there are no note' do
      it 'return nil' do
        @user.save
        expect(@user.random_diary).to be_nil
      end
    end
  end
end

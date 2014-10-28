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
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{DateTime.now.to_i}#{n}@example.com" }
    timezone User.timezones[2]
  end
end

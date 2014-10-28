# == Schema Information
#
# Table name: mail_receivers
#
#  id         :integer          not null, primary key
#  address    :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#  timezone   :string(255)      not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mail_receiver do
    sequence(:address) { |n| "mail_receiver#{DateTime.now.to_i}#{n}" }
    user
  end
end

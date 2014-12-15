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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mail_receiver do
    user
  end
end

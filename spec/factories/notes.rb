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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note do
    from_email { mail_receiver.user.email }
    content 'hello world'
    mail_receiver
  end
end

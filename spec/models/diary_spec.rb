# == Schema Information
#
# Table name: diaries
#
#  id             :integer          not null, primary key
#  from_email     :string(255)      not null
#  content        :text             not null
#  user_id        :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#  note_date      :date             not null
#  sender_address :string(255)      not null
#

require 'spec_helper'

describe Diary do
  pending "add some examples to (or delete) #{__FILE__}"
end

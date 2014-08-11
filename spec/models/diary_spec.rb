# == Schema Information
#
# Table name: diaries
#
#  id         :integer          not null, primary key
#  from_email :string(255)
#  content    :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Diary do
  pending "add some examples to (or delete) #{__FILE__}"
end

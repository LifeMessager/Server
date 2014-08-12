# == Schema Information
#
# Table name: mail_senders
#
#  id         :integer          not null, primary key
#  address    :string(255)      not null
#  receiver   :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe MailSender do
  pending "add some examples to (or delete) #{__FILE__}"
end

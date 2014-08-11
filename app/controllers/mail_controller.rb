class MailController < ApplicationController
  def receivers
    user = User.find_by_email params["sender"]
    diary = user.diaries.build from_email: params['sender'], content: params['stripped-text']
    if diary.save
      respond nil, status: 201
    else
      puts 'diary save error'
      puts diary.errors
      respond nil, status: 500
    end
  end
end

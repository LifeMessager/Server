class MailController < ApplicationController
  def receivers
    ms = MailSender.find_by_address get_sender_address params['recipient']
    user = User.find_by_email ms.receiver

    diary = user.diaries.build(
      from_email: params['sender'],
      content: params['stripped-text'],
      sender_address: ms.address,
      note_date: ms.note_date,
      created_at: params['Date']
    )

    if diary.save
      respond nil, status: :created
    else
      puts 'diary save error'
      puts diary.errors
      respond nil, status: :internal_server_error
    end
  end

  private

  def get_sender_address(mail)
    mail[/^([^@]+).*$/, 1]
  end
end

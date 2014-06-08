class MailController < ApplicationController
  def receivers
    puts "received email: #{params["stripped-text"]}"
    respond nil, status: 201
  end
end

class UsersController < ApplicationController
  skip_before_action :verify_token, only: [:create, :unsubscribe, :send_login_mail]

  def create
    user = User.new info_of_user
    if user.save
      UserMailer.welcome(user).deliver
      respond user, status: :created
    else
      data = build_resp 'Register failed', user.errors
      respond data, status: :unprocessable_entity
    end
  end

  def subscribe
    user = User.find_by_id params[:user_id]
    return respond(nil, status: :not_found) unless user
    user.subscribe
    if user.save
      respond nil, status: :created
    else
      data = build_resp 'Subscribe failed', user.errors
      respond data, status: :unprocessable_entity
    end
  end

  def unsubscribe
    user = User.find_by_id params[:user_id]
    return respond(nil, status: :not_found) unless user
    error = build_resp 'Header Authorization is required'
    unless authorization && authorization[:token] && authorization[:type] == 'unsubscribe'
      return respond(error, status: :unauthorized)
    end
    user.unsubscribe token: authorization[:token]
    if user.save
      respond nil, status: :no_content
    else
      data = build_resp 'Unsubscribe failed', user.errors
      respond data, status: :unprocessable_entity
    end
  end

  def send_login_mail
    user = User.find_by_email params[:email]
    UserMailer.login(user).deliver
    respond nil, status: :created
  end

  private

  def info_of_user
    params.permit :email
  end
end

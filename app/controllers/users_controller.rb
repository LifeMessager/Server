class UsersController < ApplicationController
  skip_before_action :verify_token, only: [:create, :unsubscribe, :send_login_mail]

  def create
    user = User.new info_of_user
    if user.save
      UserMailer.welcome(user).deliver
      simple_respond user, status: :created
    else
      data = build_error 'Register failed', user.errors
      simple_respond data, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by_id params[:id]
    return simple_respond(nil, status: :not_found) unless @user
  end

  def subscribe
    user = User.find_by_id params[:user_id]
    return simple_respond(nil, status: :not_found) unless user
    user.subscribe
    if user.save
      simple_respond nil, status: :created
    else
      data = build_error 'Subscribe failed', user.errors
      simple_respond data, status: :unprocessable_entity
    end
  end

  def unsubscribe
    user = User.find_by_id params[:user_id]
    return simple_respond(nil, status: :not_found) unless user
    unless authorization && authorization[:token] && authorization[:type] == 'unsubscribe'
      return simple_respond(nil, status: :unauthorized)
    end
    user.unsubscribe token: authorization[:token]
    if user.save
      simple_respond nil, status: :no_content
    else
      data = build_error 'Unsubscribe failed', user.errors
      simple_respond data, status: :unprocessable_entity
    end
  end

  def send_login_mail
    user = User.find_by_email params[:email]
    UserMailer.login(user).deliver
    simple_respond nil, status: :created
  end

  private

  def info_of_user
    params.permit :email, :timezone
  end
end

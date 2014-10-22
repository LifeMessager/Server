class UsersController < ApplicationController
  def create
    user = User.new info_of_user
    if user.save
      DiaryMailer.welcome(user).deliver
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
    return respond(error, status: :unauthorized) unless unsubscribe_token
    user.unsubscribe token: unsubscribe_token
    if user.save
      respond nil, status: :no_content
    else
      data = build_resp 'Unsubscribe failed', user.errors
      respond data, status: :unprocessable_entity
    end
  end

  private

  def info_of_user
    params.permit :email
  end

  def unsubscribe_token
    if authorization = request.authorization
      token = authorization
    elsif params[:_method] && params[:_method].downcase == 'delete'
      token = params[:token]
    end

    token.gsub(/^unsubscribe /, '') if token
  end
end

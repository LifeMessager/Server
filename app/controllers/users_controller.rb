class UsersController < ApplicationController
  def create
    user = User.new params_for_create
    if user.save
      UserMailer.welcome(user).deliver
      respond user, status: 201
    else
      data = { errors: user.errors, message: 'Register failed' }
      respond data, status: 422
    end
  end

  private

  def params_for_create
    params.permit :email
  end
end

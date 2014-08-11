class UsersController < ApplicationController
  def create
    user = User.new params_for_create
    if user.save
      UserMailer.welcome(user).deliver
      respond user, status: :created
    else
      data = { errors: user.errors, message: 'Register failed' }
      respond data, status: :unprocessable_entity
    end
  end

  private

  def params_for_create
    params.permit :email
  end
end

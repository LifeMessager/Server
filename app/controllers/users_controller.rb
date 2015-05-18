class UsersController < ApplicationController
  skip_before_action :verify_token, only: [:create, :unsubscribe, :change_email]
  before_action :check_params_user, except: [:create, :get_current_user]

  def create
    unless User.creatable?
      return simple_respond build_error('Registered user overflow'), status: :forbidden
    end
    @user = User.new user_info_for_create
    @user.language ||= http_accept_language.language_region_compatible_from User.languages
    @user.timezone = current_timezone
    @user.alert_time ||= '08:00'
    unless @user.save
      data = build_error 'Register failed', @user.errors
      return simple_respond data, status: :unprocessable_entity
    end
    UserMailer.welcome(@user).deliver_now
    respond_to do |format|
      format.json { render json: @user, status: :created, location: @user }
      format.xml  { render  xml: @user, status: :created, location: @user }
    end
  end

  def show
    respond_to do |format|
      format.json
      format.xml
    end
  end

  def update
    unless @user.update user_info_for_update
      data = build_error 'Update failed', @user.errors
      return simple_respond data, status: :unprocessable_entity
    end
    respond_to do |format|
      format.json
      format.xml
    end
  end

  def destroy
    if @user.destroy
      UserMailer.destroyed(@user).deliver_now
      simple_respond nil, status: :no_content
    else
      data = build_error 'Destroy user failed', @user.errors
      simple_respond data, status: :unprocessable_entity
    end
  end

  def cancel_destroy
    if @user.deleted?
      User.restore @user.id
    end
    simple_respond nil, status: :no_content
  end

  def subscribe
    @user.subscribe
    if @user.save
      simple_respond nil, status: :created
    else
      data = build_error 'Subscribe failed', @user.errors
      simple_respond data, status: :unprocessable_entity
    end
  end

  def unsubscribe
    unless authorization && authorization[:token] && authorization[:type] == 'unsubscribe'
      return simple_respond(nil, status: :unauthorized)
    end
    @user.unsubscribe token: authorization[:token]
    if @user.save
      simple_respond nil, status: :no_content
    else
      data = build_error 'Unsubscribe failed', @user.errors
      simple_respond data, status: :unprocessable_entity
    end
  end

  def apply_change_email
    if valid_params_email.nil?
      data = build_error 'Validation Failed', [resource: 'User', field: 'email', code: 'invalid']
      return simple_respond data, status: :unprocessable_entity
    end
    if current_user.email != valid_params_email
      UserMailer.change_email(current_user, params[:email]).deliver_now
    end
    simple_respond nil, status: :created
  end

  def change_email
    unless authorization && authorization[:token] && authorization[:type] == 'change_email'
      return simple_respond nil, status: :unauthorized
    end
    if @user.change_email authorization[:token]
      simple_respond nil, status: :ok
    else
      simple_respond nil, status: :unauthorized
    end
  end

  def get_current_user
    @user = current_user
    respond_to do |format|
      format.json
      format.xml
    end
  end

  private

  def check_params_user
    @user = User.with_deleted.find_by_id params[:id]
    return simple_respond(nil, status: :not_found) unless @user
  end

  def user_info_for_create
    params.permit :email, :timezone, :alert_time, :language
  end

  def user_info_for_update
    params.permit :timezone, :alert_time
  end

  def valid_params_email
    return @_valid_params_email if @_valid_params_email_called
    email = params[:email].chomp
    @_valid_params_email_called = true
    @_valid_params_email = ValidateEmail.valid?(email) ? email : nil
  end
end

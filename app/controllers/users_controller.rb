class UsersController < ApplicationController
  skip_before_action :verify_token, only: [:create, :unsubscribe, :send_login_mail]
  before_action :check_params_user, except: [:create, :send_login_mail, :get_current_user]

  def create
    @user = User.new info_of_user
    @user.language ||= http_accept_language.language_region_compatible_from User.languages
    @user.timezone = current_timezone
    @user.alert_time ||= '08:00'
    unless @user.save
      data = build_error 'Register failed', @user.errors
      return simple_respond data, status: :unprocessable_entity
    end
    UserMailer.welcome(@user).deliver
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
    unless @user.update update_info
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
      UserMailer.destroyed(@user).deliver
      simple_respond nil, status: :no_content
    else
      data = build_error 'Destroy user failed', @user.errors
      simple_respond data, status: :unprocessable_entity
    end
  end

  def cancel_destroy
    if @user.destroyed?
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

  def send_login_mail
    user = User.find_by_email params[:email].downcase
    if user.nil?
      data = build_error 'Login failed', [{resource: 'User', field: 'email', code: 'missing'}]
      return simple_respond data, status: :unprocessable_entity
    end
    UserMailer.login(user).deliver
    simple_respond nil, status: :created
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

  def info_of_user
    params.permit :email, :timezone, :alert_time, :language
  end

  def update_info
    params.permit :timezone, :alert_time
  end
end

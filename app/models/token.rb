class Token
  MAIL_EXPIRED_INTERVAL = 1.day
  EXPIRED_INTERVAL = 15.day

  attr_reader :user, :id, :expired_at

  def initialize **args
    interval = args[:expired_interval] || MAIL_EXPIRED_INTERVAL
    @expired_at = Time.now + interval
    data = {exp: @expired_at.to_i}
    if args[:user]
      @user = args[:user]
      data[:user_id] = @user.id
    end
    @id = args[:id] || JWT.encode(data, args[:secret] || secret)
  end

  def to_s
    @id
  end

  def to_url
    "http://#{Settings.server_name}/#!/login?token=#{id}"
  end
  alias_method :login_url, :to_url

  def self.decode id, **args
    begin
      info = JWT.decode(id, args[:secret] || secret).first
      user = User.with_deleted.find_by_id info['user_id']
      return {success: false, message: 'user not exist'} unless user
      {success: true, token: Token.new(user: user, id: id)}
    rescue JWT::ExpiredSignature
      {success: false, message: 'token expired'}
    rescue JWT::DecodeError
      {success: false, message: 'unprocessable token'}
    end
  end

  private

  def self.secret
    Rails.application.secrets[:secret_key_base]
  end

  def secret
    Token.secret
  end
end

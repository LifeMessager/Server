class Token
  MAIL_EXPIRED_INTERVAL = 1.day
  EXPIRED_INTERVAL = 15.day

  attr_reader :user, :id, :expired_at, :data

  def initialize **args
    if args[:id]
      @id = args[:id]
      data = JWT.decode(@id, args[:secret] || secret).first
      @user = User.with_deleted.find_by_id data['user_id']
      @data = data['data']
      @expired_at = Time.at data['exp']
    else
      @user = args[:user]
      @data = args[:data].clone if args[:data]
      interval = args[:expired_interval] || MAIL_EXPIRED_INTERVAL
      @expired_at = Time.now + interval
      data = {data: args[:data], exp: @expired_at.to_i, user_id: @user.id}
      @id = JWT.encode(data, args[:secret] || secret)
    end
  end

  def expired?
    Time.now >= @expired_at
  end

  def to_url
    "#{Settings.url_protocol}://#{Settings.server_name}/#!/login?token=#{id}"
  end

  alias_method :to_s, :id
  alias_method :login_url, :to_url

  def self.decode id, **args
    begin
      token = Token.new args.merge id: id
      return {success: false, message: 'user not exist'} unless token.user
      {success: true, token: token}
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

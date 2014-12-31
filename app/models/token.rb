class Token
  EXPIRED_INTERVAL = 1.day

  attr_reader :user, :id

  def initialize **args
    interval = args[:expired_interval] || EXPIRED_INTERVAL
    data = {exp: (Time.now + interval).to_i}
    if args[:user]
      @user = args[:user]
      data[:user_id] = @user.id
    end
    @id = args[:id] || JWT.encode(data, args[:secret] || secret)
  end

  def login_url
    "http://#{mailer_info[:domain]}/#!/login?token=#{id}"
  end

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
    Rails.application.config.jwt_secret
  end

  def secret
    Token.secret
  end

  def mailer_info
    Rails.application.config.mailer_info
  end
end

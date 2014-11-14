module CustomControllerHelper
  def login user
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{Token.new(user: user).id}"
  end

  def setup_timezone_header *timezone_header
    request.env['HTTP_TIMEZONE'] = "#{Time.now.iso8601};;Asia/Shanghai"
  end
end

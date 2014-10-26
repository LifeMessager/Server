module CustomControllerHelper
  def login user
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{Token.new(user: user).id}"
  end
end

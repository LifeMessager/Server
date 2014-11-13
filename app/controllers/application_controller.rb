# coding: utf-8

class ApplicationController < ActionController::Base
  SUPPORT_FORMAT = [:json, :xml]

  skip_before_action :verify_authenticity_token
  before_action :default_format # 这个 filter 必须放在最前面，因为它约束了响应的数据格式
  before_action :verify_token

  private

  def default_format
    unless SUPPORT_FORMAT.include? request.format
      request.format = SUPPORT_FORMAT.first
    end
  end

  def verify_token
    return simple_respond(nil, status: :unauthorized) unless current_user
  end

  def current_user
    return unless authorization
    return unless authorization[:type] == 'Bearer'
    token = Token.decode authorization[:token]
    return unless token[:success]
    token[:token].user
  end

  def authorization
    auth = request.authorization || params[:token]
    return unless auth
    auth_parts = auth.split ' ', 2
    {type: auth_parts.first, token: auth_parts.last}
  end

  def simple_respond(resp, opts)
    default_resps = {
      not_found: build_error('Resource not found'),
      unauthorized: build_error('Header Authorization is required')
    }

    if default_resp = default_resps[opts[:status]]
      resp = default_resp.merge resp || {}
    end
    format_opt = resp ? {request.format.to_sym => resp} : {nothing: true}
    render format_opt.merge opts
  end

  def build_error message, *args
    {message: message, errors: args.first || []}
  end
end

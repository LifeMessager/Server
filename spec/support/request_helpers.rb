
# http://matthewlehner.net/rails-api-testing-guidelines/
module Requests
  module JSONHelpers
    def respond_json
      return if response.body.nil? or response.body.empty?
      @json ||= JSON.parse response.body
    end
  end
end

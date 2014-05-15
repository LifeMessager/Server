
# http://matthewlehner.net/rails-api-testing-guidelines/
module Requests
  module JSONHelpers
    def respond_json
      @json ||= JSON.parse response.body
    end
  end
end


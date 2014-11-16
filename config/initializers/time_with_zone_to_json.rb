module ActiveSupport
  class TimeWithZone
    alias_method :as_json, :iso8601
  end
end

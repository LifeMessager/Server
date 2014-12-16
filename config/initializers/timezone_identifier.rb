module ActiveSupport
  class TimeZone
    def identifier
      tzinfo.name
    end

    def to_json *args
      "\"#{identifier}\""
    end

    alias_method :as_json, :identifier
  end
end

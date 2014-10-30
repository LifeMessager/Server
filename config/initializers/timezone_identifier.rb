module ActiveSupport
  class TimeZone
    def identifier
      tzinfo.name
    end

    alias_method :as_json, :identifier
  end
end

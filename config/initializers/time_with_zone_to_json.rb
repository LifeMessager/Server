module ActiveSupport
  class TimeWithZone
    def as_json *args
      iso8601
    end
  end
end

class DateTime
  def as_json *args
    iso8601
  end
end

class Time
  def as_json *args
    iso8601
  end
end

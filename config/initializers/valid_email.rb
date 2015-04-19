# From: https://github.com/hallelujah/valid_email/blob/master/lib/valid_email/email_validator.rb
class EmailValidator
  def validate_each record, attribute, value
    return if options[:allow_nil] && value.nil?
    return if options[:allow_blank] && value.blank?

    r = ValidateEmail.valid?(value)
    # Check if domain has DNS MX record
    if r && options[:mx]
      r = MxValidator.new(:attributes => attributes).validate(record)
    elsif r && options[:mx_with_fallback]
      r = MxWithFallbackValidator.new(:attributes => attributes).validate(record)
    end
    # Check if domain is disposable
    if r && options[:ban_disposable_email]
      r = BanDisposableEmailValidator.new(:attributes => attributes).validate(record)
    end
    # From https://github.com/rails/rails/blob/e0f29c51b9bbb41f4235d0948103194096d92cd9/activemodel/lib/active_model/validations/format.rb#L32
    record.errors.add(attribute, :invalid, options.merge(value: value)) unless r
  end
end

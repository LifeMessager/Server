# Rails extending ActiveRecord::Base
# http://stackoverflow.com/questions/2328984/rails-extending-activerecordbase

# Is there a way to make Rails ActiveRecord attributes private?
# http://stackoverflow.com/questions/3764899/is-there-a-way-to-make-rails-activerecord-attributes-private

class ReadonlyAttrError < NoMethodError
end

module ActiveRecordReadonlyAttrExtension
  extend ActiveSupport::Concern

  # add your static(class) methods here
  module ClassMethods
    def readonly_attributes *attrs
      attrs.each do |attr|
        method_name = "#{attr.to_s}=".to_sym

        define_method(method_name) do |value|
          write_attribute attr, value
        end

        private method_name
      end
    end
  end
end

# include the extension
ActiveRecord::Base.send :include, ActiveRecordReadonlyAttrExtension

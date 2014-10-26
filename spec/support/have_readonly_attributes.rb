require 'rspec/expectations'

module CustomMatchers
  class HaveReadonlyAttribute
    def initialize attribute
      @attribute = attribute
    end

    def description
      "have readonly attribute: #{@attribute}"
    end

    def matches? instance
      @instance = instance
      readable and not writeable
    end

    def failure_message
      prefix = "expected to have a readonly attribute '#{@attribute}', but it "
      prefix + (not readable ? 'not readable' : 'writeable')
    end

    def failure_message_when_negated
      prefix = "expected to have a accessible attribute '#{@attribute}', but it "
      prefix + (not readable ? 'not readable' : 'not writeble')
    end

    private

    def readable
      @instance.respond_to? @attribute
    end

    def writeable
      @instance.respond_to? "#{@attribute.to_s}="
    end
  end

  def have_readonly_attribute attribute
    HaveReadonlyAttribute.new attribute
  end

  def self.included base
    if base.respond_to? :register_matcher
      instance_methods.each do |name|
        base.register_matcher name, name
      end
    end
  end
end

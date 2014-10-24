require "email_spec"
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

module ModelError
  def self.BLANK
    /\.blank$/
  end

  def self.TAKEN
    /\.taken$/
  end

  def self.INVALID
    /\.invalid$/
  end
end

class Array
  def to_proc
    proc { |receiver| receiver.send :[], *self }
  end
end

module I18n
  class SpecErrorMessage < String
    attr_reader :key
    attr_reader :options

    def initialize key, options
      @key = key.to_s
      @options = options
      super @key
    end
  end

  def self.t(*args)
    options  = args.last.is_a?(Hash) ? args.pop.dup : {}
    key      = args.shift

    if key.is_a? Array
      key.map { |token| I18n::SpecErrorMessage.new token, options }
    else
      I18n::SpecErrorMessage.new key, options
    end
  end
end
class << I18n
  alias :origin_translate :translate
  alias :translate :t
end

RSpec.configure do |config|
  # http://matthewlehner.net/rails-api-testing-guidelines/
  config.include Requests::JSONHelpers

  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.include FactoryGirl::Syntax::Methods

  config.include CustomMatchers
end

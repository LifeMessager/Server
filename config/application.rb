require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # http://stackoverflow.com/questions/4235264/how-can-i-make-sure-rails-doesnt-generate-spec-tests-for-views-and-helpers
    config.generators do |generators|
      generators.assets false
      generators.helper false
      generators.template_engine nil
      generators.view_specs false
      generators.helper_specs false
    end

    config.action_mailer.preview_path = "#{Rails.root}/app/mailer_previews"
    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
      api_key: ENV['MAILGUN_API_KEY'],
      domain:  ENV['MAILGUN_DOMAIN']
    }

    config.i18n.default_locale = 'zh-CN'
    config.i18n.available_locales = ['zh-CN', 'zh-TW', :en, 'en-US']
    I18n.load_path += Dir[Rails.root.join('config', 'locale', '*.{yml|rb}').to_s]
  end
end

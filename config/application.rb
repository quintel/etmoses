require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ivy
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

    # Paperclip
    # ---------

    paperclip_path = 'system/:class/:attachment/:id_partition/' +
                     ':basename.:style.:extension'

    config.paperclip_defaults = {
      path: ":rails_root/public/#{ paperclip_path }",
      url:  "/#{ paperclip_path }"
    }
  end

  # Public: Path to the directory in which static data files files typically
  # reside. This will normally have subfolders like curves/, technologies/, etc.
  #
  # Returns a Pathname.
  def self.data_dir
    @data_dir ||= Rails.root.join('data')
  end

  # Public: Sets the path to the direction in which the data files reside.
  #
  # Returns the path provided.
  def self.data_dir=(path)
    path = path.is_a?(Pathname) ? path : Pathname.new(path.to_s)
    path = Rails.root.join(path) if path.relative?

    Rails.cache.clear

    @data_dir = path
  end

  # Public: Wrap around a block of code to work with a temporarily altered
  # +data_dir+ setting.
  #
  # directory - The new, but temporary, data_dir path.
  #
  # Returns the result of your block.
  def self.with_data_dir(directory)
    previous      = data_dir
    self.data_dir = directory

    yield
  ensure
    self.data_dir = previous
  end
end # Ivy

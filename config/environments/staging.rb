require File.expand_path(File.dirname(__FILE__)) + '/production'

Rails.application.configure do
  # Temporarily use in-memory caching.
  config.cache_store = :memory_store, { size: 64.megabytes }

  config.action_mailer.default_url_options = { host: 'http://ivy.etloader.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default charset: 'utf-8'
  config.action_mailer.smtp_settings = YAML.load_file(File.open(File.join("config", "email.yml")))[Rails.env].freeze

  ET_MODEL_URL = "beta.pro.et-model.com"
end

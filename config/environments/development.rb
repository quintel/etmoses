Rails.application.configure do
  config.cache_classes                       = false
  config.eager_load                          = false
  config.consider_all_requests_local         = true
  config.action_controller.perform_caching   = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation          = :log
  config.active_record.migration_error       = :page_load
  config.assets.debug                        = true
  config.assets.raise_runtime_errors         = true

  ET_MODEL_URL = "beta.pro.et-model.com"

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end

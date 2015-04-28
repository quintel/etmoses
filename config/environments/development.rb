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

  config.action_mailer.smtp_settings = YAML.load_file(File.open(File.join("config", "email.yml")))[Rails.env].symbolize_keys
  config.action_mailer.delivery_method = :smtp

  ET_MODEL_URL = "beta.pro.et-model.com"
end

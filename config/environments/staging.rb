require File.expand_path(File.dirname(__FILE__)) + '/production'

Rails.application.configure do
  config.cache_store = :memory_store, { size: 64.megabytes }

  config.action_mailer.default_url_options = { host: 'http://ivy.et-engine.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default charset: 'utf-8'
  config.action_mailer.smtp_settings = { address:              'smtp.gmail.com',
                                         port:                  587,
                                         domain:               'quintel.com',
                                         user_name:            'mailserver@quintel.com',
                                         password:             'oQ3WYrX6J',
                                         authentication:       'plain',
                                         enable_starttls_auto:  true }

  ET_MODEL_URL = "beta.pro.et-model.com"
end

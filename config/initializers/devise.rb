Devise.setup do |config|
  require 'devise/orm/active_record'
  config.mailer_sender         = 'info@quintel.com'
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage  = [:http_auth]
  config.stretches             = Rails.env.test? ? 1 : 10
  config.reconfirmable         = true
  config.password_length       = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via          = :delete
end

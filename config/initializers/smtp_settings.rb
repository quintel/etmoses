ActionMailer::Base.smtp_settings = YAML.load_file(File.open(File.join("config", "email.yml")))[Rails.env].freeze

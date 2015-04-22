ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Monban.test_mode!

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Ivy::Spec::Fixtures
  config.include Monban::Test::ControllerHelpers, type: :controller

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{ Rails.root }/public/test_files/"])
  end

  config.after :each do
    Monban.test_reset!
    ActionMailer::Base.deliveries.clear
  end
end

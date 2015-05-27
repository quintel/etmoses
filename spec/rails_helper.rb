ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'webmock/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

FactoryGirl::SyntaxRunner.class_eval do
  # Enables "allow" in factories.
  include RSpec::Mocks::ExampleMethods
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Moses::Spec::Fixtures
  config.include Moses::Spec::Network
  config.include Devise::TestHelpers, type: :controller

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{ Rails.root }/public/test_files/"])
  end

  config.after :each do
    ActionMailer::Base.deliveries.clear
  end
end

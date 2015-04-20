class ApplicationController < ActionController::Base
  include Monban::ControllerHelpers

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :load_recent_testing_grounds

  def load_recent_testing_grounds
    @recent_testing_grounds = TestingGround.all.order('created_at DESC').limit(5)
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :authenticate_user!
  before_filter :load_recent_testing_grounds

  def load_recent_testing_grounds
    @recent_testing_grounds = TestingGround.all.order('created_at DESC').limit(5)
  end
end

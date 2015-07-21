class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  before_filter :authenticate_user!
  before_filter :load_recent_testing_grounds

  rescue_from Pundit::NotAuthorizedError do |ex|
    if request.format.json?
      render json: { message: t(:not_authorized) }, status: 403
    else
      redirect_to(root_path, alert: t(:not_authorized))
    end
  end

  private

  def load_recent_testing_grounds
    @recent_testing_grounds = policy_scope(TestingGround).latest_first.limit(5)
  end
end

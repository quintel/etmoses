class ResourceController < ApplicationController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  private

  def fetch_testing_ground
    @testing_ground ||= if session[:testing_ground_id]
      TestingGround.find_by_id(session[:testing_ground_id])
    else
      nil
    end
  end

  # A filter which authorizes a user to run an action, without needing to pass
  # in a TestingGround.
  def authorize_generic
    authorize controller_name.singularize.to_sym
  end
end

class ResourceController < ApplicationController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  #######
  private
  #######

  # A filter which authorizes a user to run an action, without needing to pass
  # in a TestingGround.
  def authorize_generic
    authorize controller_name.singularize.to_sym
  end
end

class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :authenticate_user!

  after_filter :store_location

  rescue_from Pundit::NotAuthorizedError do |ex|
    if request.format.json?
      render json: { message: t(:not_authorized) }, status: 403
    elsif current_user
      redirect_to(root_path)
    else
      session[:previous_url] = request.fullpath
      redirect_to(new_user_session_path, alert: t(:not_authorized))
    end
  end

  private

  def store_location
    return unless request.get?

    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?)
      session[:previous_url] = request.fullpath
    end
  end

  def configure_permitted_parameters
    %i(sign_up account_update).each do |action|
      devise_parameter_sanitizer.for(action) << :name
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end
end

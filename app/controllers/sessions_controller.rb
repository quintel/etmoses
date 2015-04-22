class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])

    if user.activated?
      user = authenticate_session(session_params)
      if sign_in(user)
        redirect_to root_path
      else
        flash.now[:alert] = "Wrong credentials"
        render :new
      end
    else
      flash.now[:alert] = "Account is not activated"
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private

    def session_params
      params.require(:session).permit(:email, :password)
    end
end


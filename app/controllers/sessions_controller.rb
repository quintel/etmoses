class SessionsController < Devise::SessionsController
  skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])

    if user && user.activated? && user.valid_password?(params[:session][:password]) && sign_in(user)
      redirect_to signed_in_redirect_path
    elsif user && !user.activated?
      flash.now[:alert] = "Account is not activated"
      render :new
    else
      flash.now[:alert] = "Wrong credentials"
      render :new
    end
  end

  def destroy
    sign_out(:user)
    redirect_to root_path
  end

  private

  def signed_in_redirect_path
    if request.env["HTTP_REFERER"]
      request.env["HTTP_REFERER"]
    else
      root_path
    end
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end
end

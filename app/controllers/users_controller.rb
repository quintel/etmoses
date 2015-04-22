class UsersController < ApplicationController
  skip_before_filter :require_login

  def new
    @registration_form = RegistrationForm.new
  end

  def create
    @registration_form = RegistrationForm.new(params[:user])
    if @registration_form.submit
      flash[:notice] = "Your account needs activation before you can sign in."
      redirect_to root_path
    else
      flash[:alert] = @registration_form.errors.messages
      render :new
    end
  end
end

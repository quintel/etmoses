class UsersController < ApplicationController
  skip_before_filter :authenticate_user!

  def new
    @registration_form = RegistrationForm.new(params[:registration_form])
  end

  def create
    @registration_form = RegistrationForm.new(params[:registration_form])
    if @registration_form.submit
      flash[:notice] = "Your account needs activation before you can sign in."
      redirect_to root_path
    else
      flash[:alert] = @registration_form.errors.full_messages.join(", ")
      render :new
    end
  end
end

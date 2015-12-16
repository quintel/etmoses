class UsersController < ApplicationController
  skip_before_filter :authenticate_user!, only: %i(new create)

  def new
    @registration_form = RegistrationForm.new(params[:registration_form])
  end

  def create
    @registration_form = RegistrationForm.new(params[:registration_form])
    if @registration_form.submit
      sign_in(:user, @registration_form.user)
      redirect_to root_path
    else
      flash[:alert] = @registration_form.errors.full_messages.join(", ")
      render :new
    end
  end

  def edit
    @users_form = UsersForm.new(current_user.attributes.slice("email", "name"))
  end

  def update
    @users_form = UsersForm.new(params[:users_form])
    @users_form.user = current_user

    if @users_form.submit
      redirect_to edit_user_registration_path
    else
      flash[:alert] = @users_form.errors.full_messages.join(", ")
      render :edit
    end
  end
end

class PagesController < ApplicationController
  before_filter :skip_authorization

  skip_before_filter :authenticate_user!

  def show
    render params[:id]
  end
end

class PagesController < ApplicationController
  before_filter :skip_authorization

  def show
    render params[:id]
  end
end

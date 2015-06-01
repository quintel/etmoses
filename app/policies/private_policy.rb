class PrivatePolicy
  include Rails.application.routes.url_helpers

  def initialize(controller, entity)
    @controller = controller
    @entity = entity
  end

  def authorize
    unless authorized?
      @controller.redirect_to redirect_path
    end
  end

  def authorized?
    @entity.public? || @controller.current_user == @entity.user
  end

  private

  def redirect_path
    @controller.url_for([@entity.class])
  end
end

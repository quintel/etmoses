class TestingGroundPolicy
  include Rails.application.routes.url_helpers

  def initialize(controller, testing_ground)
    @controller = controller
    @testing_ground = testing_ground
  end

  def authorize
    unless authorized?
      @controller.redirect_to testing_grounds_path
    end
  end

  def authorized?
    return true if @testing_ground.permissions == "public"
    return true if @testing_ground.permissions == "private" &&
                   @controller.current_user == @testing_ground.user
  end
end

class ProfilesController < ResourceController
  before_filter :authorize_generic

  skip_before_filter :authenticate_user!

  def index
    skip_policy_scope
    @load_profile_categories = LoadProfileCategory.where(parent_id: nil)
    @price_curves            = PriceCurve.all
    @temperature_profiles    = TemperatureProfile.all
  end
end

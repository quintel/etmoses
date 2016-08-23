class InstalledHeatSource
  include Virtus.model

  attribute :key, String
  attribute :name, String
  attribute :units, Float, default: 1.0
  attribute :heat_production, Float, default: 0.0
  attribute :heat_capacity, Float, default: 0.0
  attribute :total_initial_investment, Float, default: 0.0
  attribute :technical_lifetime, Float, default: 1.0
  attribute :om_costs_per_year, Float, default: 0.0
  attribute :marginal_heat_costs, Float
  attribute :profile, Integer
  attribute :stakeholder, String, default: 'heat producer'
  attribute :distance, Float
  attribute :dispatchable, Boolean
  attribute :priority, Integer

  def total_yearly_costs
    (initial_investment / technical_lifetime) + om_costs
  end

  # Public: Returns the Network::Curve which containing each of the load profile
  # values.
  def network_curve(scaling = :original)
    return unless profile

    LoadProfile.find(profile).
      load_profile_components.first.
      network_curve(scaling)
  end

  # Public: Creates a ProfileCurve representing the LoadProfile used by this
  # heat source.
  def profile_curve(range = nil)
    @profile_curve ||=
      InstalledTechnology::ProfileCurve.new(curves: get_profile, range: range)
  end

  private

  def initial_investment
    total_initial_investment.to_f * costs_multiplier
  end

  def om_costs
    om_costs_per_year * costs_multiplier
  end

  def costs_multiplier
    (dispatchable ? heat_capacity * units : heat_production)
  end

  def get_profile
    if profile && !dispatchable &&
        heat_production && (curve = network_curve(:demand_scaled))
      multi = (units.presence || 1.0) * heat_production * curve.frames_per_hour
      { 'default' => curve * multi }
    else
      { 'default' => nil }
    end
  end
end

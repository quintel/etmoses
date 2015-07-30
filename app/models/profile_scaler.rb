class ProfileScaler
  def initialize(profile_component, scaling)
    @profile_component = profile_component
    @scaling = scaling
  end

  def scale(factor)
  end

  private

  def scaled_curve
    Network::Curve.new(
      case @scaling
        when :capacity_scaled then Paperclip::ScaledCurve.scale(curve, :max)
        when :demand_scaled   then Paperclip::ScaledCurve.scale(curve, :sum)
        else curve
      end.to_a
    )
  end

  def curve
    @profile_component.network_curve
  end

  def ratio(component)
    component.reduce(:+) / combined_components.reduce(:+)
  end

  def combined_components
    @combined_components ||= profile_components.map{|com| com.network_curve }.reduce(:+)
  end

  scaled_curve(profile_component.network_curve, scaling) *
          component_factor * ratio(profile_component.network_curve)
end

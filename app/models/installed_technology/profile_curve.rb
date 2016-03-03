class InstalledTechnology
  module ProfileCurve
    # Public: Returns the load profile Curve, if the :profile attribute is set.
    #
    # Returns a Hash[{ <curve_type> => Network::Curve }]
    def get_profile
      if profile.nil?
        { default: nil }
      elsif profile.is_a?(Array)
        curve = Network::Curve.new(sliced_profile(profile))
        { default: curve * component_factor(curve) }
      elsif profile.is_a?(Hash)
        Hash[profile.each_pair.map do |curve_type, curve|
          [curve_type, Network::Curve.new(sliced_profile(curve))]
        end]
      elsif demand
        profile_curves(:demand_scaled)
      elsif volume.blank? && capacity
        profile_curves(:capacity_scaled)
      else
        profile_curves
      end
    end

    def each_profile_curve
      if has_heat_pump_profiles?
        yield(profile_curve.keys.sort.join('_'), *profile_curve.values)
      else
        profile_curve.each_pair.map do |curve_type, curve|
          yield(curve_type, curve)
        end
      end
    end

    def profile_length
      if valid_profile?
        profile_curve.first.last.length
      else
        1
      end
    end

    private

    def has_heat_pump_profiles?
      profile_curve.keys.sort == %w(availability use)
    end

    def sliced_profile(profile)
      profile_range ? profile[profile_range] : profile
    end

    # Internal: Retrieves the Network::Curve used by the technology, with
    # scaling applied for demand or capacity and a ratio.
    #
    # Returns a Hash[{ <curve_type> => Network::Curve }].
    def profile_curves(scaling = nil)
      return {} unless valid_profile?

      Hash[load_profile.curves(profile_range).each_curve(scaling).map do |curve_type, curve, ratio|
        [curve_type, curve * component_factor(curve) * ratio]
      end]
    end
  end
end

class InstalledTechnology
  class ProfileCurve
    include Virtus.model

    attribute :curves, Hash

    def length
      curves.values.compact.map(&:values).map(&:length).max || 1
    end

    def each
      if has_heat_pump_profiles?
        yield(curves.keys.sort.join('_'), *curves.values)
      else
        curves.each_pair.map do |curve_type, curve|
          yield(curve_type, curve)
        end
      end
    end

    def has_heat_pump_profiles?
      curves.keys.sort == %w(availability use)
    end
  end
end

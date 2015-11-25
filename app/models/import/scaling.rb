class Import
  module Scaling
    def valid_scaling?
      @scaling && @scaling['area_attribute'] == 'number_of_residences'
    end

    def scaling_value
      @scaling['value'].to_i
    end
  end
end

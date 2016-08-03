class Import
  # Creates the resistive electric water heater technology. This needs to adjust
  # the number of units to ensure that the ETModel power-to-heat share is
  # fully-respected in Moses.
  #
  # If an ETEngine scenario specifies that there should be a 25% share of P2H,
  # we need to ensure that the Moses LES has at least 25% of households with an
  # electric heater. If the LES should fall short of that, we add extra space
  # heater electricity technologies to compensate.
  class ResistiveWaterHeaterBuilder < Builder
    include Scaling

    TECH_KEY    = 'households_water_heater_resistive_electricity'.freeze
    SHARE_QUERY = 'share_of_p2h_in_hot_water_produced_in_households'.freeze

    def build(techs)
      if heater = techs.detect { |tech| tech['type'] == TECH_KEY }
        deficit = required_heaters - installations(techs)

        if deficit > 0
          [ heater.merge('units' => heater['units'] + deficit) ]
        else
          [ heater ]
        end
      else
        []
      end
    end

    private

    def installations(techs)
      keys = Technology.find_by_key('buffer_water_heating')
        .technologies.select do |key|
          Technology.find_by_key(key).carrier == 'electricity'
        end

      techs.sum do |tech|
        keys.include?(tech['type']) ? tech['units'] : 0
      end
    end

    def required_heaters
      scaling_value * @gqueries.fetch(SHARE_QUERY).fetch('future')
    end
  end
end

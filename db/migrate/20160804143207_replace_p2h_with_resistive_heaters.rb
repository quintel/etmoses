class ReplaceP2hWithResistiveHeaters < ActiveRecord::Migration
  RESISTIVE_KEY = 'households_water_heater_resistive_electricity'.freeze
  P2H_KEY       = 'households_flexibility_p2h_electricity'.freeze
  BUFFER_KEY    = 'buffer_water_heating'

  ELEC_TECHS = %w(
    households_flexibility_p2h_electricity
    households_water_heater_heatpump_air_water_electricity
    households_water_heater_heatpump_ground_water_electricity
    households_water_heater_hybrid_heatpump_air_water_electricity_electricity
    households_water_heater_resistive_electricity
  ).freeze

  def up
    # TestingGround.find_each do |les|
    TestingGround.find_each do |les|
      puts "Starting #{ les.id }"

      if replace_p2h!(les)
        les.save(validate: false)
        puts "  - Updated LES #{ les.id }"
      end
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end

  private

  def replace_p2h!(les)
    changed = false

    # For the given LES, determine if resisitive heaters need to be added to
    # each buffer to compensate for the removal of P2H.
    les.technology_profile.each do |_, techs|
      buffers = techs.select { |t| t.type == BUFFER_KEY }

      # For each buffer, find all technlogies attached.
      techs_by_buffer = techs.group_by(&:buffer)

      buffers.each do |buffer|
        buffer_techs =
          (techs_by_buffer[buffer.composite_value] || []).select do |t|
            # We care only about electricity technologies when balancing the
            # amount of resistive heaters with P2H.
            ELEC_TECHS.include?(t.type)
          end

        if p2h = buffer_techs.detect { |v| v.type.to_s == P2H_KEY }
          non_p2h_units = (buffer_techs - [p2h]).sum(&:units)
          deficit = p2h.units - non_p2h_units

          if deficit > 0
            # There are not enough electric heaters to satisfy the needs of P2H,
            # therefore we need to add resistive heaters to compensate.
            resistive = buffer_techs.detect { |t| t.type == RESISTIVE_KEY }

            if ! resistive
              # Replace the P2H technology with a resistive heater.
              techs[techs.index(p2h)] =
                new_heater(buffer.composite_value, deficit)
            else
              # Increase the number of resistive units.
              resistive.units += deficit

              # Remove the P2H heater.
              techs.delete(p2h)
            end

            changed = true
          end
        end
      end
    end

    changed
  end

  def buffer_tech
    @bt ||= Technology.find_by_key(BUFFER_KEY)
  end

  def new_heater(buffer, units)
    InstalledTechnology.new(
      "buffer" => buffer,
      "capacity" => 1.5,
      "composite" => false,
      "composite_value" => nil,
      "congestion_reserve_percentage" => nil,
      "demand" => nil,
      "position_relative_to_buffer" => "buffering",
      "profile" => nil,
      "type" => "households_water_heater_resistive_electricity",
      "units" => units,
      "volume" => nil,
      "composite_index" => nil,
      "concurrency" => "max",
      "full_load_hours" => 1636,
      "includes" => [],
      "initial_investment" => 135.0,
      "om_costs_for_ccs_per_full_load_hour" => nil,
      "om_costs_per_full_load_hour" => nil,
      "om_costs_per_year" => 3.0,
      "performance_coefficient" => 1.0,
      "technical_lifetime" => 15,
      "associates" => [],
      "node" => nil,
      "profile_key" => nil
    )
  end
end

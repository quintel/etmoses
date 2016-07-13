# Takes testing grounds and creates a full-size national scenario on ETEngine,
# based on the original scaled-down scenario and accounting for changes made in
# the testing ground.
class Export
  include ActiveModel::Validations

  validate :validate_share_groups

  def initialize(testing_ground)
    @testing_ground = testing_ground
  end

  # Public: Creates a hash containing the inputs and values to be sent to
  # ETEngine in order to reflect the state of the testing ground.
  #
  # Returns a Hash.
  def exported_technologies
    technology_units.map do |technology, units|
      value = (units / factor_for_tech(technology.key) / number_of_households) * 100

      ExportedTechnology.new(attributes_for_tech(technology, value))
    end
  end

  def grouped_inputs
    exported_technologies.group_by(&:share_group)
  end

  # Public: Sends requests to ETEngine in order to create the national scenario.
  #
  # Returns the JSON response body as a Hash.
  def export
    NationalScenarioCreator.new(@testing_ground, exported_technologies).create
  end

  private

  # Private: Creates a hash desribing each technology and the number of units of
  # said technology in the testing ground.
  #
  # Each key is the key of a technology, and each value the number of units.
  #
  # Returns a Hash.
  def technology_units
    technologies.each_with_object({}) do |tech, object|
      object[tech.technology] = (object[tech.technology] || 0) + tech.units
    end
  end

  def exportable(technology)
    Technology.exists?(technology.type) &&
      Technology.by_key(technology.type).export_to.present?
  end

  def technologies
    @testing_ground.technology_profile.to_h.values.flatten
      .select(&method(:exportable))
  end

  def attributes_for_tech(tech, value)
    tech.attributes.slice(:key, :export_to)
      .merge(raw_setting: value)
      .merge(ete_inputs[tech.export_to])
  end

  def factor_for_tech(key)
    if key == "households_solar_pv_solar_radiation"
      solar_panel_units_factor
    else
      1
    end
  end

  # Private: Queries ETEngine to determine the average amount of solar panels
  # for a single household
  #
  # Returns a Float
  def solar_panel_units_factor
    et_engine_gqueries['number_of_solar_pv']['future'] / number_of_households
  end

  # Private: Queries ETEngine to determine how many households exist in the
  # (scaled-down) scenario.
  #
  # Returns an Integer.
  def number_of_households
    et_engine_gqueries['households_number_of_residences']['future']
  end

  def et_engine_gqueries
    @et_engine_gqueries ||= EtEngineConnector.new(gqueries:
      %w(households_number_of_residences number_of_solar_pv)
    ).gquery(@testing_ground.scenario_id)
  end

  # Private: The ETENgine input data, including the minimum and maximum
  # permitted values.
  #
  # Returns a Hash.
  def ete_inputs
    @ete_inputs ||= EtEngineConnector.new.inputs(@testing_ground.scenario_id)
  end

  # Private: Validates share groups
  #
  def validate_share_groups
    valid = Hash.new{ |k,v| k[v] = 0 }

    exported_technologies.each_with_object(valid) do |tech, result|
      valid[tech.share_group] += tech.slider_setting
    end

    valid.each do |share_group, percentage|
      if percentage > 100 && share_group != 'no_group'
        errors.add(:base, "Please limit your units for share group #{ I18n.t("groups.#{ share_group }") } to 100%")
      end
    end
  end
end

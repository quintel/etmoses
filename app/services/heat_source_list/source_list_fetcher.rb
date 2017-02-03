# frozen_string_literal: true

class HeatSourceList::SourceListFetcher
  def initialize(testing_ground)
    @testing_ground = testing_ground
  end

  # create an array with set attributes
  #
  # [ { key: '', units: '', etc. } ]
  def fetch
    technologies.each_with_index.map do |tech, priority|
      tech.merge(priority: priority, stakeholder: default_stakeholder)
    end
  end

  private

  def technologies
    sources = (default_heat_sources + central_heat_network)

    sources.reject! { |tech| tech['units'].zero? }
    sources.sort_by! { |tech| tech['marginal_heat_costs'] || -1 }

    sources
  end

  def default_stakeholder
    InstalledHeatSource.attribute_set[:stakeholder].default_value.call
  end

  def central_heat_network
    Import::CentralHeatNetworkBuilder.build(@testing_ground.scenario_id)
  end

  def default_heat_sources
    response.each_pair.map do |key, attributes|
      Import::HeatSourceBuilder.build(key, attributes)
    end
  end

  def response
    @response ||= EtEngineConnector.new(keys: heat_source_keys)
                  .stats(@testing_ground.scenario_id)['nodes']
  end

  def heat_source_keys
    Hash[Technology.heat_sources.map do |heat_source|
      [heat_source.key, heat_source.importable_attributes]
    end]
  end
end

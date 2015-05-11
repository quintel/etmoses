module TestingGroundsHelper
  def import_topology_select_tag(form)
    topologies = Topology.all.reverse.map do |topo|
      [(topo.name || "No name specified"), topo.id]
    end

    topologies.unshift(['- - -', '-', { disabled: true }])
    topologies.unshift(['Default topology', nil])

    form.select(:topology_id, topologies, {}, class: 'form-control')
  end

  def technologies_field_value(testing_ground)
    if testing_ground.new_record? && testing_ground.technologies.blank?
      TestingGround::DEFAULT_TECHNOLOGIES
    else
      YAML.dump(testing_ground_technologies(testing_ground).map(&:to_hash))
    end
  end

  def testing_ground_technologies(testing_ground)
    testing_ground.technologies.map do |technology|
      technology.reject do |unit, value|
        InstalledTechnology.template[unit] == value &&
        InstalledTechnology.template.key?(unit)
      end
    end
  end

  def technological_topology_field_value(testing_ground)
    YAML.dump(JSON.parse(testing_ground.technology_profile.to_json))
  end

  def link_to_etm_scenario(title, scenario_id)
    link_to(title, "http://#{ ET_MODEL_URL }/scenarios/#{ scenario_id }")
  end
end

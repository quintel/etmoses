module TestingGroundsHelper
  def national_scenario_select_options
    TestingGround.where('`parent_scenario_id` IS NOT NULL')
                 .order(:parent_scenario_id)
                 .pluck(:parent_scenario_id)
                 .uniq
                 .map{|s| [s,s]}
  end

  def local_scenario_select_options
    TestingGround.where('`scenario_id` IS NOT NULL')
                 .order(:scenario_id)
                 .pluck(:scenario_id)
                 .uniq
                 .map{|s| [s,s]}
  end

  def import_topology_select_tag(form)
    topologies = Topology.all.reverse.map do |topo|
      if testing_ground = TestingGround.where(topology_id: topo.id).first
        [testing_ground.name, topo.id]
      end
    end.compact

    topologies.unshift(['- - -', '-', { disabled: true }])
    topologies.unshift(['Default topology', nil])

    form.select(:topology_id, topologies, {}, class: 'form-control')
  end

  def topology_field_value(testing_ground)
    if testing_ground.new_record? && testing_ground.topology.graph.blank?
      Topology::DEFAULT_GRAPH
    else
      YAML.dump(testing_ground.topology.graph.to_hash)
    end
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

  end

  def link_to_etm_scenario(title, scenario_id)
    link_to(title, "http://#{ ET_MODEL_URL }/scenarios/#{ scenario_id }")
  end
end

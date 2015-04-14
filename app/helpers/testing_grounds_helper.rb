module TestingGroundsHelper
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
      YAML.dump(testing_ground.topology.graph)
    end
  end

  def technologies_field_value(testing_ground)
    if testing_ground.new_record? && testing_ground.technologies.blank?
      TestingGround::DEFAULT_TECHNOLOGIES
    else
      defaults = Hash[InstalledTechnology.attribute_set.map do |attr|
        [attr.name, attr.default_value.call]
      end]

      YAML.dump(Hash[testing_ground.technologies.map do |node, techs|
        [node, techs.map { |t| technology_attributes(t, defaults) }]
      end])
    end
  end

  def technology_attributes(technology, defaults)
    technology.attributes.reject do |key, value|
      defaults.key?(key) && defaults[key] == value
    end.stringify_keys
  end
end

module TestingGroundsHelper
  def import_engine_select_tag(form)
    display_names = {
      'etengine.dev'   => 'etengine.dev (local only)',
      'localhost:3000' => 'localhost:3000 (local only)'
    }

    providers = TestingGround::IMPORT_PROVIDERS.map do |url|
      [display_names[url] || url, url]
    end

    form.select(:provider, options_for_select(providers))
  end

  def import_topology_select_tag(form)
    topologies = Topology.all.reverse.map do |topo|
      if testing_ground = TestingGround.where(topology_id: topo.id).first
        [testing_ground.name, topo.id]
      end
    end.compact

    topologies.unshift(['Default topology', nil])

    form.select(:topology_id, topologies)
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
      YAML.dump(Hash[testing_ground.technologies.map do |node, techs|
        [node, techs.map { |t| t.to_h.compact.stringify_keys }]
      end])
    end
  end
end

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
        ["Topology from #{ testing_ground.created_at.to_formatted_s(:long) } " \
         "testing ground", topo.id]
      end
    end.compact

    topologies.unshift(['Default topology', nil])

    form.select(:topology_id, topologies)
  end
end

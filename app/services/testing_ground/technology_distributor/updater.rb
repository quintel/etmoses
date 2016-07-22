class TestingGround
  module TechnologyDistributor::Updater
    def update_technology(tech, index)
      @technology            = tech

      dup_technology         = tech.dup
      dup_technology.profile = profile_selector(dup_technology).select_profile
      dup_technology.node    = edge_nodes[index + edge_nodes_index].key

      if dup_technology.sticks_to_composite?
        create_buffer(dup_technology)
      else
        dup_technology
      end
    end

    private

    def edge_nodes_index
      less_buildings_than_nodes? ? households.units : 0
    end

    def less_buildings_than_nodes?
      is_building? && (@technology.units + households.units) < edge_nodes.size
    end

    def is_building?
      @technology.type == 'base_load_buildings'
    end

    def households
      @technologies.detect do |technology|
        technology.type == 'base_load'
      end
    end
  end
end

module NetworkCache
  module CacheHelper
    CARRIERS = [:electricity, :gas]

    def initialize(testing_ground, opts = nil)
      @testing_ground = testing_ground
      @opts           = opts || { strategies: {} }
    end

    def tree_scope
      @tree_scope ||= begin
        tree  = @testing_ground.topology.graph
        techs = @testing_ground.technology_profile

        CARRIERS.map do |carrier|
          Network::Builders.for(carrier).build(tree, techs)
        end
      end
    end

    def file_name(carrier, key)
      file_path.join(carrier.to_s).join("#{Digest::SHA256.hexdigest(key)}.tmp")
    end

    def file_path
      Rails.root.join("tmp/networks/#{Rails.env}/#{@testing_ground.id}/#{strategy_prefix}/#{resolution}")
    end

    def strategy_prefix
      SelectedStrategy.strategy_type(@opts[:strategies] || {})
    end

    def resolution
      @opts[:range] && @opts[:range].size === 35041 ? 'low' : 'high'
    end
  end
end

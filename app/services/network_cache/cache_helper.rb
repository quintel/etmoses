module NetworkCache
  module CacheHelper
    CARRIERS = [:electricity, :gas]
    FOLDERS  = {
      low:  'year',
      high: 'current_week'
    }.freeze

    def initialize(testing_ground, strategies: {}, range: nil, resolution: :high)
      @testing_ground = testing_ground
      @strategies     = strategies
      @range          = range
      @resolution     = resolution
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

    def file_name(carrier, key, time_frame = time_frame)
      file_path.join(carrier.to_s, time_frame).join("#{Digest::SHA256.hexdigest(key)}.tmp")
    end

    def file_path
      Rails.root.join("tmp/networks/#{Rails.env}/#{@testing_ground.id}/#{strategy_prefix}")
    end

    def strategy_prefix
      SelectedStrategy.strategy_type(@strategies)
    end

    def time_frame
      FOLDERS[@resolution] || FOLDERS.values.last
    end
  end
end

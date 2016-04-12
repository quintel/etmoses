module NetworkCache
  module CacheHelper
    ATTRS    = [:load, :tech_loads]
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

    def file_name(carrier, key, attr = 'load', time_frame = time_frame)
      carrier_path(carrier).join(file_key(key, attr, time_frame))
    end

    def file_path
      Rails.root.join("tmp/networks/#{Rails.env}/#{@testing_ground.id}/#{strategy_prefix}/")
    end

    def strategy_prefix
      SelectedStrategy.strategy_type(@strategies)
    end

    def time_frame
      FOLDERS[@resolution] || FOLDERS.values.last
    end

    private

    def carrier_path(carrier)
      file_path.join(carrier.to_s)
    end

    def file_key(key, *extras)
      [Digest::SHA256.hexdigest(key.to_s), *extras, 'tmp'].join('.')
    end
  end
end

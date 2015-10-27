module NetworkCache
  module CacheHelper
    def initialize(testing_ground, opts)
      @testing_ground = testing_ground
      @opts = opts || {}
    end

    def tree_scope
      @tree_scope ||= TreeToGraph.convert(@testing_ground.topology.graph)
    end

    def file_name(key)
      "#{ file_path }/#{ Digest::SHA256.hexdigest(key) }.tmp"
    end

    def file_path
      "#{Rails.root}/tmp/networks/#{Rails.env}/#{@testing_ground.id}/#{strategy_prefix}"
    end

    def strategy_prefix
      @opts.except(:capping_fraction).values.any? ? 'features' : 'basic'
    end
  end
end

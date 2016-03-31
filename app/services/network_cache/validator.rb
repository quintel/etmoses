module NetworkCache
  class Validator
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, **opts)
    end

    def valid?
      Settings.cache.networks &&
        (cache_intact?('year') || (cache_intact? && identical_range?)) &&
        fresh? && identical_strategies?
    end

    private

    def cache_intact?(time_frame = time_frame)
      tree_scope.all? do |network|
        network.nodes.all? do |node|
          File.exists?(file_name(network.carrier, node.key, time_frame))
        end
      end
    end

    def identical_strategies?
      @strategies.empty? || strategy_attributes == @strategies
    end

    def identical_range?
      @range.nil? || (@testing_ground.range == @range)
    end

    def fresh?
      [ @testing_ground.cache_updated_at,
        @testing_ground.topology.updated_at].all? do |timestamp|
          Time.at(timestamp.to_time.to_i) <= Time.at(cache_time.to_i)
      end
    end

    def cache_time
      tree_scope.map do |network|
        network.nodes.map do |node|
          File.mtime(file_name(network.carrier, node.key))
        end.min
      end.min
    end

    def strategy_attributes
      @testing_ground.selected_strategy.attributes.except("id", "testing_ground_id")
    end
  end
end

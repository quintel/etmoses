module NetworkCache
  class Fetcher
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, **opts)
    end

    #
    # Fetches all cache and sets is as the load attribute for a node
    def fetch(nodes = nil)
      tree_scope.each do |network|
        LoadSetter.set(network, nodes) do |node|
          if year = read(network.carrier, node.key, 'year')
            year[@range ? @range : 0..-1]
          elsif current_week = read(network.carrier, node.key, 'current_week')
            current_week
          end
        end
      end

      tree_scope
    end

    def read(carrier, key, time_frame)
      file = file_name(carrier, key, time_frame)

      if File.exists?(file)
        MessagePack.unpack(File.read(file))
      end
    end
  end
end

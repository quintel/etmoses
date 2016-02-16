module NetworkCache
  class Fetcher
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    #
    # Fetches all cache and sets is as the load attribute for a node
    def fetch(nodes = nil)
      tree_scope.each do |network|
        network.set_loads(nodes) do |node|
          read(network.carrier, node.key) || []
        end
      end

      tree_scope
    end

    def read(carrier, key)
      MessagePack.unpack(File.read(file_name(carrier, key)))
    end
  end
end

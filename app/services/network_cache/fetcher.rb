module NetworkCache
  class Fetcher
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    #
    # Fetches all cache and sets is as the load attribute for a node
    def fetch
      tree_scope.nodes.each do |node|
        node.set(:load, read(node.key) || [])
      end

      tree_scope
    end

    def read(key)
      MessagePack.unpack(File.read(file_name(key)))
    end
  end
end

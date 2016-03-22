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
        LoadSetter.set(network, nodes) do |node|
          read(network.carrier, node.key) || []
        end

        LoadSetter.set(network, nodes, :tech_loads) do |node|
          read_tech_loads(network.carrier, node.key) || {}
        end
      end

      tree_scope
    end

    def read(carrier, key)
      MessagePack.unpack(File.read(file_name(carrier, key)))
    end

    def read_tech_loads(carrier, key)
      MessagePack.unpack(File.read(tech_load_file_name(carrier, key)))
    end
  end
end

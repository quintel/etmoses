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

        LoadSetter.set(network, nodes, :tech_loads) do |node|
          read_tech_loads(network.carrier, node.key) || {}
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

    def read_tech_loads(carrier, key)
      MessagePack.unpack(File.read(tech_load_file_name(carrier, key)))
    end
  end
end

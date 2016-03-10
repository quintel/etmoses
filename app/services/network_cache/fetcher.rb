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
          caches = FOLDERS.values.map do |frame|
            read(file_name(network.carrier, node.key, frame))
          end

          (caches.detect(&:present?) || [])[@range ? @range : 0..-1]
        end
      end

      tree_scope
    end

    def read(file)
      if File.exists?(file)
        MessagePack.unpack(File.read(file))
      end
    end
  end
end

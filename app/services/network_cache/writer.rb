module NetworkCache
  class Writer
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    #
    # Writes a load calculation to cache
    def write(network = tree_scope)
      network.nodes.each do |node|
        unless File.directory?(file_path)
          FileUtils.mkdir_p(file_path)
        end

        File.write(file_name(node.key), node.get(:load).to_msgpack, mode: 'wb')
      end

      network
    end
  end
end

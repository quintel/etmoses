module NetworkCache
  class Destroyer
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    #
    # Destroys all network cache with and without strategies
    def destroy_all
      FileUtils.rm_rf(file_path.sub(/[^\/]*$/, ''))
    end

    #
    # Destroys the network cache (with or without strategies)
    def destroy
      tree_scope.nodes do |node|
        if File.exists?(file_name(node.key))
          File.delete(file_name(node.key))
        end
      end
    end
  end
end

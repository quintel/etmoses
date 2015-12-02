module NetworkCache
  class Destroyer
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    #
    # Destroys all network cache with and without strategies
    def destroy_all
      FileUtils.rm_rf(file_path.parent)
    end

    #
    # Destroys the network cache (with or without strategies)
    def destroy
      FileUtils.rm_rf(file_path)
    end
  end
end

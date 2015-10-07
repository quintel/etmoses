module NetworkCache
  class Writer
    include FilePath

    #
    # Writes a load calculation to cache

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    def initialize(testing_ground, opts = {})
      @testing_ground = testing_ground
      @opts = opts
    end

    def write(key, cache_data)
      unless File.directory?(file_path)
        FileUtils.mkdir_p(file_path)
      end

      File.write(file_name(key), cache_data.to_msgpack, mode: 'wb')
    end
  end
end

module NetworkCache
  class Reader
    include FilePath

    #
    # Reads load calculation from cache

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    def initialize(testing_ground, opts = {})
      @testing_ground = testing_ground
      @opts = opts
    end

    def read(key)
      MessagePack.unpack(File.read(file_name(key)))
    end
  end
end

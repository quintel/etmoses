module NetworkCache
  class Cache
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    def write(networks)
      Writer.from(@testing_ground, @opts).write(networks)
    end

    def fetch
      Fetcher.from(@testing_ground, @opts).fetch
    end

    def present?
      Validator.from(@testing_ground, @opts).valid?
    end
  end
end

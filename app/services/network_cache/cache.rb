module NetworkCache
  class Cache
    include CacheHelper

    def initialize(testing_ground, opts = {})
      @testing_ground = testing_ground
      @opts = opts
    end

    def write(networks)
      Writer.from(@testing_ground, **@opts).write(networks)
    end

    def fetch(nodes = [])
      Fetcher.from(@testing_ground, **@opts).fetch(nodes)
    end

    def present?
      Validator.from(@testing_ground, **@opts).valid?
    end
  end
end

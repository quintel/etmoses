class TestingGround::Calculator
  def initialize(testing_ground, options)
    @testing_ground = testing_ground
    @options        = options || {}
  end

  def calculate
    base.merge(graph: GraphToTree.convert(fetch_network))
  end

  private

  def fetch_network
    if cache.present?
      cache.fetch
    else
      cache.write(@testing_ground.to_calculated_graph(@options))
    end
  end

  def cache
    @cache ||= NetworkCache::Cache.new(@testing_ground, @options)
  end

  def base
    { technologies: @testing_ground.technology_profile.as_json }
  end
end

module NetworkCache
  class Fetcher
    #
    # Fetches all cache and sets is as the load attribute for a node

    def initialize(context)
      @context = context
    end

    def self.call(context)
      new(context).fetch
      context
    end

    def fetch
      @context.graph.nodes.each do |node|
        node.set(:load,
          NetworkCache::Reader.from(@context.testing_ground, @context.options)
            .read(node.key) || [])
      end
    end
  end
end

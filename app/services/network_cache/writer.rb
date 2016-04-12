module NetworkCache
  class Writer
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, **opts)
    end

    #
    # Writes a load calculation to cache
    def write(networks = tree_scope)
      networks.each do |network|
        write_network(file_path, network)
      end

      networks
    end

    private

    def write_network(path, network)
      FileUtils.mkdir_p(carrier_path(network.carrier))

      network.nodes.each do |node|
        ATTRS.each do |attr|
          File.write(
            file_name(network.carrier, node.key, attr),
            node.get(attr).to_msgpack,
            mode: 'wb'
          )
        end
      end
    end
  end
end

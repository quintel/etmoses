module NetworkCache
  class Fetcher
    include CacheHelper

    def self.from(testing_ground, opts = {})
      new(testing_ground, **opts)
    end

    #
    # Fetches all cache and sets is as the load attribute for a node
    #
    # It checks both 'FOLDERS'; as in scopes (current week and year)
    # for a cache. If the full year cache is already present it should use
    # that cache and cut that range out.
    def fetch(nodes = nil)
      tree_scope.each do |network|
        ATTRS.each do |attr|
          LoadSetter.set(network, nodes, attr) do |node|
            if year = read(network.carrier, node.key, attr, 'year')
              cut_year_range(year)
            elsif current_week = read(network.carrier, node.key, attr, 'current_week')
              current_week
            end
          end
        end
      end

      tree_scope
    end

    def read(carrier, key, attr, time_frame)
      file = file_name(carrier, key, attr, time_frame)

      if File.exists?(file)
        MessagePack.unpack(File.read(file))
      end
    end

    private

    def cut_year_range(year)
      if year.is_a?(Array)
        year[@range ? @range : 0..-1]
      elsif year.is_a?(Hash)
        Hash[year.map do |tech, values|
          [tech, cut_year_range(values)]
        end]
      end
    end
  end
end

module NetworkCache
  class Validator
    include FilePath

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    def initialize(testing_ground, opts = {})
      @testing_ground = testing_ground
      @opts = opts
    end

    def valid?(force_clear = false)
      return false if force_clear

      @testing_ground.topology.each_node.all? do |node|
        File.exists?(file_name(node[:name]))
      end
    end
  end
end

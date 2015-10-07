module NetworkCache
  class Destroyer
    include FilePath

    def self.from(testing_ground, opts = {})
      new(testing_ground, opts)
    end

    def initialize(testing_ground, opts = {})
      @testing_ground = testing_ground
      @opts = opts
    end

    #
    # Destroys all network cache with and without strategies
    def destroy_all
      [{}, {_: true}].each do |opts|
        @opts = opts
        destroy
      end
    end

    #
    # Destroys the network cache (with or without strategies)
    def destroy
      @testing_ground.topology.each_node do |node|
        if File.exists?(file_name(node[:name]))
          File.delete(file_name(node[:name]))
        end
      end
    end
  end
end

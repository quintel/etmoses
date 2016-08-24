class TestingGround
  class TechnologyDistributor
    module BufferCreator
      include TechnologyPartitioner::CompositeCoupler

      def create_buffer(technology)
        @buffer_counter.add(buffer.type)

        buffer_clone            = buffer.clone
        buffer_clone.profile    = profile_selector(buffer_clone).select_profile
        buffer_clone.node       = technology.node
        buffer_clone.units      = technology.units
        buffer_clone.associates = [technology]

        couple_composites(buffer_clone, @buffer_counter.get(buffer.type))
      end

      private

      def buffer
        @technologies.detect { |tech| tech.includes.include?(@technology.type) }
      end
    end
  end
end

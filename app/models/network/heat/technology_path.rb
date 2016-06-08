module Network
  module Heat
    class TechnologyPath < Network::TechnologyPath
      def initialize(technology, path)
        super

        # Hacky magic. :(
        technology.object.park = head.get(:park)
      end

      # Internal: Heat consumers take energy from the central production park
      # stored on the head node.
      #
      # Returns an array of SubPaths.
      def sub_paths
        @sub_paths ||= [super.last]
      end

      private def sub_path_class
        Heat::SubPath
      end
    end # TechnologyPath
  end # Heat
end

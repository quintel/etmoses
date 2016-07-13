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
      # Note that SubPath#distance always returns Float::INFINITY to ensure that
      # central heat production is always used first. If `sub_paths` is ever
      # changed to return more than one path, SubPath#distance will need to be
      # changed.
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

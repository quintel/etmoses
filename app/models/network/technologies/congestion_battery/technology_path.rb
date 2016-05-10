module Network::Technologies
  module CongestionBattery
    class TechnologyPath < Network::TechnologyPath
      # Public: Returns the sub-paths to the head node.
      def sub_paths
        # The congestion battery currently does not work correctly if computed
        # multiple times; as a result, we have to limit it to only resolving
        # congestion problems on the parent node.
        @sub_paths ||= begin
          all_paths = super
          solo_path = all_paths.first

          solo_path.solver_path = all_paths[1] || solo_path

          [solo_path]
        end
      end

      # Internal: A copy of the sub-path between the head network node and the
      # technology. Used to take energy from the grid.
      def full_sub_path
        # This is a SubPath, without the special features of
        # CongestionSubPath.
        @full_sub_path = Network::SubPath.from(self).last
      end

      def conditional_consumption_at(frame)
        constrain(frame, @technology.conditional_consumption_at(frame, self))
      end

      private def sub_path_class
        CongestionBattery::SubPath
      end
    end # Path
  end # CongestionBattery
end # Network::Technologies

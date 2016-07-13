module Network
  module Heat
    class SubPath < Network::SubPath
      def mandatory_consumption_at(frame)
        wanted    = @full_path.technology.mandatory_consumption_at(frame)
        available = park.available_production_at(frame)

        wanted < available ? wanted : available
      end

      # Internal: Retrieves the production park which will be used to satisfy
      # the demands of heat consumers.
      #
      # Returns a ProductionPark.
      def park
        @park ||= @full_path.path.head.get(:park)
      end

      # Public: Ensures that the central heat producers are always used to
      # satisfy heat demand first.
      #
      # Returns infinity.
      def distance
        Float::INFINITY
      end
    end # SubPath
  end # Heat
end

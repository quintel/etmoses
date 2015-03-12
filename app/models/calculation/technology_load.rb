module Calculation
  # Given
  class TechnologyLoad
    def self.call(graph)
      new(graph).run
    end

    def initialize(graph)
      @graph = graph
      @order = Merit::Order.new

      @tech_nodes = graph.nodes.select { |node| node.get(:techs).any? }

      @length = @tech_nodes.map { |n| n.get(:techs) }.flatten.map do |tech|
        tech.profile ? tech.profile_curve.length : 1
      end.max
    end

    def run
      add_participants!
      @order.calculate if @order.participants.any?
      assign_loads!

      @graph
    end

    #######
    private
    #######

    # Steps
    # -----

    # Internal: Iterates through all the technologies defined in the graph, and
    # adds each one to the merit order.
    def add_participants!
      @tech_nodes.each do |node|
        mo_techs = node.get(:techs).select do |tech|
          merit_order_tech?(tech)
        end

        # We add each merit order participant to the order, but keep track of
        # each participant and its associated technology so that we can
        # correctly set the loads later.
        node.set(:mo_techs, mo_techs.map do |tech|
          @order.add(participant_for(tech))
        end)
      end
    end

    # Internal: After the merit order has been run, assigns the technology load
    # back to the node.
    def assign_loads!
      @tech_nodes.each do |node|
        @length.times do |point|
          node.set_load(point, node.get(:mo_techs).reduce(0.0) do |sum, parti|
            # We use point zero, since we only calculated a single point.
            amount = parti.load_curve.get(point)

            # Producers need their load switching back to a negative.
            sum + (parti.is_a?(Merit::Producer) ? -amount : amount)
          end)
        end
      end
    end

    # Helpers
    # -------

    # Internal: Determines if the given technology should be included in the
    # merit order calculation.
    def merit_order_tech?(technology)
      technology.profile || technology.capacity || technology.load
    end

    # Internal: Given a Technology, returns an appropriate Merit::Participant
    # which may be used within the merit order.
    def participant_for(technology)
      if technology.profile
        # Could be a consumer or producer; we can't tell without inspecting the
        # curve. We *can* do that when calculating a single point, but there are
        # occasions where the answer is ambigous (what is a load of 0?).
        #
        # We take the one point we care about from the original curve, and use
        # a new curve -- containing only that one point -- in the participant.
        Merit::User.create(
          key:        [technology.name, SecureRandom.uuid],
          load_curve: technology.profile_curve
        )
      else
        # Consumer or a producer; again, we can't really be sure which.
        Merit::User.create(
          key:        [technology.name, SecureRandom.uuid],
          load_curve: Merit::Curve.new([technology.load || 0.0] * @length)
        )
      end
    end
  end # TechLoad
end # Calculation

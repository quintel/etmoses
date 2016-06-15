class TestingGround::HeatSummary
  COMPOSITES = %w(buffer_space_heating buffer_water_heating).freeze

  # Public: Creates a new HeatSummary, which describes the supply and demand of
  # heat in an LES.
  #
  # networks - A TestingGround::Calculator.
  #
  # Returns a HeatSummary.
  def initialize(networks)
    @electricity = networks.network(:electricity)
    @heat        = networks.network(:heat)
    @park        = @heat.head.get(:park)

    @resolution  = networks.options.fetch(:resolution, :high)
    @range       = networks.options.values_at(:range_start, :range_end)
  end

  # Public: Summarises the heat supply and demand for the LES.
  #
  # Returns a hash.
  def as_json(*)
    { calculation: { range: @range, resolution: @resolution },
      buffer: buffer_load,
      demand: demand_load,
      supply: supply_load }
  end

  private

  # Internal: Summarises heat demand in the network by the buffer type.
  #
  #   { buffer_water_heating: [0, 1, 2, ..., 671],
  #     buffer_space_heating: [0, 1, 2, ..., 671] }
  #
  # Returns a hash.
  def demand_load
    heat_composites.each_with_object({}) do |(type, composites), data|
      type       = type.to_s.sub(/\Abuffer_/, '').to_sym
      data[type] = compact_zeros(composites.flat_map(&:demand).reduce(:+))
    end
  end

  # Internal: Describes the net load of the heat network buffer.
  #
  # Positive numbers indicate the buffer is "charging", negative numbers signify
  # "discharge".
  #
  # Returns an Array.
  def buffer_load
    compact_zeros(@park.buffer_tech.net_load)
  end

  # Internal: The total amount of heat supplied by all producers in the LES.
  #
  # The total production of each technology type is summarised, and all
  # production by "local" technologies on endpoints is combined into a single
  # array.
  #
  # For example
  #
  #   { central_tech_one: [0, 1, 2, ..., 671],
  #     central_tech_two: [0, 1, 2, ..., 671],
  #     local:            [0, 1, 2, ..., 671] }
  #
  # Returns a Hash.
  def supply_load
    central_supply.merge(local: local_supply)
  end

  # Internal: A summary of energy produced by central heat producers in the
  # production park.
  #
  # Returns a hash.
  def central_supply
    producers = @park.producers.map { |prod| TechnologySummary.new(prod) }

    producers.each_with_object({}) do |tech, data|
      data[tech.key] = compact_zeros(tech.load)
    end
  end

  # Internal: The total amount of heat supplied by "local" technologies on
  # endpoints for each frame.
  #
  # Returns an Array.
  def local_supply
    compact_zeros(
      heat_composites.values.flatten.flat_map do |composite|
        # "Non-local" techs (Heat::Consumers) take energy from the heat network
        # and are already accounted for in `supply_load`.
        composite.techs.select(&:local?).map(&:load)
      end.compact.reduce(:+)
    )
  end

  # Internal: Returns all the heat-related composites in the network.
  #
  # Returns a hash where each key is a type of buffer, and each value an array
  # of Composite::Managers.
  def heat_composites
    @heat_composites ||= begin
      comp_nodes = @electricity.nodes.select { |node| node.get(:comps) }

      COMPOSITES.each_with_object({}) do |type, data|
        data[type] =
          comp_nodes.flat_map do |node|
            node.get(:comps)
              .select { |name, _| composite_type(node, name) == type }.values
              .map    { |comp| CompositeSummary.new(comp) }
          end
      end
    end
  end

  # Internal: Determines the type of a buffer.
  #
  # node - The node to which the buffer belongs.
  # name - The unique name assigned to the buffer.
  #
  # Returns a string.
  def composite_type(node, name)
    node.get(:installed_comps).detect do |inst|
      inst.composite_value == name
    end.type
  end

  # Internal: Arrays containing only zeros are replaced with an empty array.
  #
  # Load arrays which contain all zeros (no production or consumption) do not
  # need to be transferred to the client. Save on data transfer by sending an
  # empty array instead.
  #
  # Returns an Array.
  def compact_zeros(array)
    array.nil? || array.all? { |v| v.zero? } ? [] : array
  end

  # --

  class CompositeSummary
    def initialize(comp)
      @comp = comp
    end

    def demand
      Network::Curve.from(@comp.demand)
    end

    def techs
      @comp.techs.map { |tech| TechnologySummary.new(tech) }
    end
  end # CompositeSummary

  class TechnologySummary
    def initialize(tech)
      @tech = tech
    end

    # Public: Returns if the technology is attached to an endpoint. True if so,
    # false if the tech is a central heat consumer.
    def local?
      ! @tech.is_a?(Network::Heat::Consumer)
    end

    def key
      @tech.installed.key
    end

    # Public: Describes the load of a technology, adjusting for output
    # efficiency as necessary.
    #
    # Returns a Network::Curve.
    def load
      curve = Network::Curve.from(@tech.load)
      cop   = @tech.installed.try(:performance_coefficient)

      cop && cop.to_f != 1.0 ? curve * cop : curve
    end
  end # TechnologySummary
end # HeatSummary

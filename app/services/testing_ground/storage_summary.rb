# Given a computed Electricity network, summarises the amount of energy reserved
# in P2P and EV storage technologies, and the the volume empty.
class TestingGround::StorageSummary
  include Enumerable

  # Technologies whose volumes should be included in the summary.
  TECHS = [
    Network::Technologies::Battery,
    Network::Technologies::CongestionBattery::Battery,
    Network::Technologies::ElectricVehicle
  ]

  def initialize(network)
    @network  = network
    @divisors = {}
    @volume   = techs.sum { |tech| tech.volume / divisor_for(tech) }
  end

  # Public: Returns how many frames are in the calculation.
  def length
    @length ||= techs.map(&:profile).map(&:length).max || 35040
  end

  # Public: Iterates through each frame in the calculation, yielding the frame
  # number, total amount of energy stored, and total amount available.
  #
  # Returns nothing.
  def each
    return enum_for(:each) unless block_given?

    length.times.each do |frame|
      used = techs.sum { |tech| tech.stored.at(frame) / divisor_for(tech) }
      free = @volume - used

      yield frame, used, free
    end

    nil
  end

  private

  def techs
    @techs ||= @network.nodes.flat_map do |node|
      (node.get(:techs) || []).select { |tech| TECHS.include?(tech.class) }
    end
  end

  def divisor_for(tech)
    @divisors[tech] ||=
      (tech.installed.performance_coefficient || 1.0) *
      tech.profile.frames_per_hour
  end
end

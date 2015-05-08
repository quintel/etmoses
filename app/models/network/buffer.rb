module Network
  # Buffers are a hybrid consumption/storage technology. A profile is used to
  # define the energy consumed, but it may also store excess energy from the
  # network for later use (this preventing the need to draw energy from the
  # grid later). Energy stored in the buffer may only be used to satisfy its own
  # consumption, and it not released back to the network.
  class Buffer < Storage
    # Public: An array where each element describes the total amount of energy
    # stored in the technology in each time-step.
    #
    # Returns a DefaultArray.
    def stored
      @stored ||= DefaultArray.new do |frame|
        mandatory_consumption_at(frame) - profile.at(frame)
      end
    end

    # Public: Determines the minimum amount of energy the technology consumes in
    # a given time-step.
    #
    # The mandatory consumption of a buffer is the maxiumum of:
    #
    #   * The amount currently stored in the buffer, since we must "reclaim"
    #     that which is emitted as production (as a buffer may not discharge
    #     back into the network); or,
    #   * The amount of energy the profile demands.
    #
    # See Network::Technology#mandatory_consumption_at
    #
    # Returns a numeric.
    def mandatory_consumption_at(frame)
      production = production_at(frame)
      required   = profile.at(frame)

      production > required ? production : required
    end
  end # Buffer
end # Network

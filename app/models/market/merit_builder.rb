module Market
  class MeritBuilder
    def initialize(participants, curves, demand)
      @participants = participants
      @curves       = curves
      @demand       = demand
    end

    def to_merit_order
      order = Merit::Order.new

      @participants.each do |participant|
        order.add(participant_from(participant.symbolize_keys))
      end

      order.add(Merit::User.create(
        key: :consumption,
        # Moses demands are in kWh, Merit expects MWh.
        load_curve: Merit::Curve.new(
          # Sums each 15-minute consumption into total hourly consumption, then
          # convert to MJ (since Merit profiles expect MJ).
          @demand
            .each_slice(4).map { |hour| hour.reduce(:+) }
            .map { |v| v / 1000 * 3600 }
        )
      ))

      order.calculate
    end

    def price_curve
      InterpolatedCurve.new(
        # The merit price is per-MWh; Moses wants per-kWh.
        to_merit_order.price_curve.to_a.map { |v| v / 1000 },
        @demand.length
      )
    end

    private

    def participant_from(participant)
      klass = case participant[:type]
        when 'dispatchable' then Merit::DispatchableProducer
        when 'volatile'     then Merit::VolatileProducer
        when 'must_run'     then Merit::MustRunProducer
      end

      if participant[:profile]
        participant[:load_profile] =
          Merit::Curve.new(@curves[participant[:profile]])
      end

      klass.new(participant)
    end
  end # MeritBuilder
end

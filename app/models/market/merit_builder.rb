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
        load_curve: Merit::Curve.new(@demand)
      ))

      order
    end

    def price_curve
      InterpolatedCurve.new(
        to_merit_order.calculate.price_curve.to_a,
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

      participant[:curve_length] = @demand.length

      if participant[:profile]
        participant[:load_profile] = Market::InterpolatedCurve.new(
          @curves[participant[:profile]], @demand.length)
      end

      klass.new(participant)
    end
  end
end

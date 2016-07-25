module Market
  class FromMarketModelBuilder
    # Maps measures in the Detector which extracts the things to be measured
    # from the network. If the measure is not specified in the hash, the default
    # measurable will be used.
    DETECTORS =
      Hash.new { Detectors::Default.new }.tap do |m|
        m[:heat_kwh_produced] = Detectors::ParkProducers.new
      end.freeze

    def initialize(testing_ground, network, variants = {})
      @les      = testing_ground
      @model    = testing_ground.market_model
      @network  = network
      @variants = variants
    end

    def to_market
      Builder.new(data).to_market
    end

    private

    def data
      { relations: relations,
        variants: @variants }
    end

    def relations
      ignore = [:kw_flex, :kw_connection]

      relations = @model.interactions.map do |inter|
        measure    = inter['foundation'].downcase.to_sym
        detector   = DETECTORS[measure]
        applied_to = inter['applied_stakeholder'] || inter['stakeholder_from']

        {
          from:        inter['stakeholder_from'],
          to:          inter['stakeholder_to'],
          measure:     measure,
          detector:    detector,
          measurables: detector.measurables(applied_to, @network, @variants),
          applied_to:  applied_to,
          tariff:      convert_tariff(inter['tariff_type'], inter['tariff'])
        }
      end

      relations.reject do |relation|
        ignore.include?(relation[:measure])
      end
    end

    def convert_tariff(type, tariff)
      case type
        when 'merit' then merit_curve.price_curve
        when 'curve' then PriceCurve.find_by_key(tariff).network_curve
        else              tariff.to_f
      end
    end

    def merit_curve
      return @merit_curve if @merit_curve

      @merit_curve ||= MeritCurveBuilder.new(@les, @network).merit
    end
  end # FromMarketModelBuidler
end

module Market
  class FromMarketModelBuilder
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
      {
        relations: relations,
        measurables: measurables,
        variants: @variants
      }
    end

    def relations
      ignore = [:kw_flex, :kw_connection]

      relations = @model.interactions.map do |inter|
        {
          from:       inter['stakeholder_from'],
          to:         inter['stakeholder_to'],
          measure:    inter['foundation'].downcase.to_sym,
          applied_to: inter['applied_stakeholder'],
          tariff:     convert_tariff(inter['tariff_type'], inter['tariff'])
        }
      end

      relations.reject do |relation|
        ignore.include?(relation[:measure])
      end
    end

    def measurables
      measurables = Hash.new { |hash, key| hash[key] = [] }

      @network.nodes.select { |node| node.get(:stakeholder) }.each do |node|
        measurables[node.get(:stakeholder)].push(node)
      end

      measurables
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

      @merit_curve ||= MeritCurveBuilder.new(@les, @network).build
    end
  end # FromMarketModelBuidler
end

module Market
  class FromMarketModelBuilder < Builder
    def initialize(model, les)
      super(data_from_model(model, les))
    end

    private

    def data_from_model(model, les)
      {
        relations: relations_from_model(model),
        measurables: measurables_from_les(les)
      }
    end

    def relations_from_model(model)
      ignore = [:kw_flex, :kw_connection]

      relations = model.interactions.map do |inter|
        {
          from:    inter['stakeholder_from'],
          to:      inter['stakeholder_to'],
          measure: inter['foundation'].downcase.to_sym,
          tariff:  convert_tariff(inter['tariff'])
        }
      end

      relations.reject do |relation|
        ignore.include?(relation[:measure])
      end
    end

    def measurables_from_les(les)
      measurables = Hash.new { |hash, key| hash[key] = [] }

      les.nodes.select { |node| node.get(:stakeholder) }.each do |node|
        measurables[node.get(:stakeholder)].push(node)
      end

      measurables
    end

    def convert_tariff(tariff)
      case tariff
      when Numeric
        tariff
      when /\A[a-z0-9_\s]+\z/i
        PriceCurve.find_by_key(tariff).network_curve
      else
        tariff.to_f
      end
    end
  end # FromMarketModelBuidler
end

module Market
  class MeritCurveBuilder
    def initialize(les, network)
      @les       = les
      @network   = network
    end

    def merit
      @merit_curve ||= MeritBuilder.new(
        *merit_data.values_at('participants', 'profiles'), consumption.to_a
      )
    end

    private

    def root
      @network.nodes.detect { |node| node.in_edges.none? }
    end

    def consumption
      load_curve.map do |kw|
        kw < 0 ? 0.0 : kw * load_curve.resolution
      end
    end

    def load_curve
      @load_curve ||= Network::Curve.from(root.load)
    end

    def merit_data
      @merit_data ||= EtEngineConnector.new.merit(@les.scenario_id)
    end
  end
end

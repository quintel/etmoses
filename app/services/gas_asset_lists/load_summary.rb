module GasAssetLists
  class LoadSummary
    # Human names of each pressure level and the corresponding network layer.
    LEVELS = {
      'Endpoints ↔ 0.125 bar' => :local,
      '0.125 bar ↔ 4 bar'     => :four,
      '4 bar ↔ 8 bar'         => :eight,
      '8 bar ↔ 40 bar'        => :forty
    }

    def initialize(network)
      @network    = network
      @range      = 0..672
    end

    def to_h
      {
        name: 'Gas load chart',
        values: LEVELS.map do |name, key|
          { name: name, type: "gas_#{key}", load: summarize_load(key) }
        end
      }
    end

    alias_method :as_json, :to_h

    private

    def summarize_load(key)
      connection = @network.public_send(key)

      if key != :local
        connection = connection.children.first
      end

      each_frame.map { |frame| connection.output_at(frame) }
    end

    def each_frame
      return enum_for(:each_frame) unless block_given?

      @range.each { |frame| yield(frame) }
    end
  end # LoadSummary
end

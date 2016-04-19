module GasAssetLists
  class LoadSummary
    # Human names of each pressure level and the corresponding network layer.
    LEVELS = {
      '0.125 bar ↔ 4 bar' => :four,
      '4 bar ↔ 8 bar'     => :eight,
      '8 bar ↔ 40 bar'    => :forty
    }

    def initialize(network)
      @network = network
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
      connection = @network.public_send(key).children.first
      full_loads = each_frame.map { |frame| connection.output_at(frame) }

      full_loads.each_slice(96).map { |loads| loads.max_by(&:abs) }
    end

    def each_frame
      return enum_for(:each_frame) unless block_given?

      # TODO This shouldn't be hard-coded, but presently the gas network does
      # not return a length, and the total gas demand - which does have a
      # length - is not exposed publicly.
      (0...35040).each { |frame| yield(frame) }
    end
  end # LoadSummary
end

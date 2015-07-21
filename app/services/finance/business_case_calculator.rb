module Finance
  class BusinessCaseCalculator
    def initialize(testing_ground)
      @testing_ground = testing_ground
    end

    def rows
      headers.map do |column_header|
        Hash[ column_header, cells(column_header) ]
      end
    end


    def headers
      Stakeholder.all.sort
    end

    private

      def cells(column_header)
        headers.map do |stakeholder|
          row(column_header, stakeholder)
        end
      end

      def row(header, stakeholder)
        return unless header == stakeholder

        @testing_ground.market_model.interactions.detect do |interaction|
          interaction['stakeholder_from'] == stakeholder
        end
      end
  end
end

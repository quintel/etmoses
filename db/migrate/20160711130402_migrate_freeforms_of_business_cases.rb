class MigrateFreeformsOfBusinessCases < ActiveRecord::Migration
  def change
    BusinessCase.select { |b| b.financials && b.financials.any? }
      .each do |business_case|
        financials = business_case.financials
        freeform   = financials.last

        #
        # Check if the business case has a freeform filled
        if freeform && freeform['freeform'].present? && freeform['freeform'].is_a?(Array)
          new_freeform = {}

          # Loop through all financials except the last value
          #
          # Create a Hash with { <stakeholder> => freform_value }
          #
          # like:
          #
          #  { customer => 0.0,
          #    ...
          #  }
          financials[0...-1].each_with_index do |row, index|
            stakeholder = row.keys[0]

            new_freeform[stakeholder] = freeform['freeform'][index]
          end

          # Remove the old freeform value
          # push the new one
          #
          financials.pop
          financials.push(freeform: new_freeform)
        end

        business_case.financials = financials
        business_case.save
      end
  end
end

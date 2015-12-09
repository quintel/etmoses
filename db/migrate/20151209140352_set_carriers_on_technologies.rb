class SetCarriersOnTechnologies < ActiveRecord::Migration
  def change
    Technology.reset_column_information

    Technology.find_each do |tech|
      if tech.key.match(/network_gas/)
        tech.update_attributes!(carrier: 'gas')
      else
        tech.update_attributes!(carrier: 'electricity')
      end
    end
  end
end

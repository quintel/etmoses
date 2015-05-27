class AddStorageVolumeImportAttributes < ActiveRecord::Migration
  def up
    technologies.each do |tech|
      ImportableAttribute.create!(name: 'storage.volume', technology: tech)
    end
  end

  def down
    ImportableAttribute.where(
      technology: technologies, name: 'storage.volume'
    ).delete_all
  end

  private

  def technologies
    Technology.where(key: %w(
      households_flexibility_p2h_electricity
      households_flexibility_p2p_electricity
      transport_car_using_electricity
    ))
  end
end

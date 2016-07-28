class AssetList < ActiveRecord::Base
  belongs_to :testing_ground

  serialize :asset_list, AssetListSerializer

  def asset_list=(asset_list)
    if asset_list.is_a?(String)
      super(JSON.parse(asset_list))
    else
      super(asset_list)
    end
  end

  def stakeholders
    Set.new(asset_list.map { |item| item[:stakeholder] }.compact)
  end
end

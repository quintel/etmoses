class InstalledHeatAsset
  include Virtus.model

  attribute :type, String
  attribute :scope, String
  attribute :stakeholder, String, default: 'system operator'
  attribute :technical_lifetime, Float

  def primary?
    is_a?(InstalledHeatAssetPipe)
  end

  def secondary?
    is_a?(InstalledHeatAssetLocation)
  end
end

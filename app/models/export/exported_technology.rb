class Export::ExportedTechnology
  include Virtus.model

  attribute :key, String
  attribute :export_to, String
  attribute :max, Float
  attribute :min, Float
  attribute :share_group, String, default: "no_group"
  attribute :raw_setting, Float

  def slider_setting
    [ [raw_setting, max].min, min ].max.round(2)
  end
end

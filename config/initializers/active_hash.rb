Rails.application.config.to_prepare do
  StaticData.load_data!

  ActionDispatch::Reloader.to_prepare do
    StaticData.load_data!
  end
end

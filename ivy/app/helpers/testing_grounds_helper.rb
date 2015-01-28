module TestingGroundsHelper
  def import_engine_select_tag(form)
    display_names = {
      'etengine.dev'   => 'etengine.dev (local only)',
      'localhost:3000' => 'localhost:3000 (local only)'
    }

    providers = TestingGround::IMPORT_PROVIDERS.map do |url|
      [display_names[url] || url, url]
    end

    form.select(:provider, options_for_select(providers))
  end
end

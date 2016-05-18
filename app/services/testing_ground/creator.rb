class TestingGround::Creator
  def initialize(testing_ground)
    @testing_ground = testing_ground
  end

  def create
    if @testing_ground.valid?
      BusinessCase.create!(testing_ground: @testing_ground)
      SelectedStrategy.create!(testing_ground: @testing_ground)

      create_heat_source_list!
      create_gas_asset_list!

      Delayed::Job.enqueue BusinessCaseCalculatorJob.new(@testing_ground)
    end

    @testing_ground
  end

  private

  def create_heat_source_list!
    HeatSourceList.create!(testing_ground: @testing_ground, source_list:
      HeatSourceList::SourceListFetcher.new(@testing_ground).fetch
    )
  end

  def create_gas_asset_list!
    GasAssetList.create!(testing_ground: @testing_ground, asset_list:
      GasAssetLists::AssetListGenerator.new(@testing_ground).generate
    )
  end
end

class CreateSelectedStrategyForTestingGrounds < ActiveRecord::Migration
  def change
    TestingGround.all.each do |testing_ground|
      unless testing_ground.selected_strategy
        SelectedStrategy.create!(testing_ground: testing_ground)
      end
    end
  end
end

class TestingGround::Destroyer
  def self.destroy(testing_ground)
    testing_ground.destroy

    destroy_part(testing_ground.topology)
    destroy_part(testing_ground.market_model)
  end

  def self.destroy_part(object)
    key = object.class.name.underscore

    if TestingGround.where(key => object).count > 0
      object.update_attribute(:user, User.orphan)
    else
      object.destroy
    end
  end
end

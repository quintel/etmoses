class TestingGround::Destroyer
  def self.run(testing_ground)
    owner = testing_ground.user

    testing_ground.destroy

    destroy_part(testing_ground.topology, owner)
    destroy_part(testing_ground.market_model, owner)
  end

  def self.destroy_part(object, owner = nil)
    # Leave the object alone if it belongs to someone else...
    return if owner && owner != object.user

    # ... or if the owner is still using it.
    return if owner && object.testing_grounds.where(user: owner).count > 0

    if object.testing_grounds.count > 0
      object.update_attribute(:user, User.orphan)
    else
      object.destroy
    end
  end
end

class TestingGround::Cloner
  def initialize(testing_ground, object, params)
    @testing_ground = testing_ground
    @object = object
    @params = params
  end

  def clone
    if in_use?
      @testing_ground.update_attribute(object_id_property, cloned_object.id)
    else
      @object.update_attributes(@params)
    end

    if @testing_ground.business_case
      @testing_ground.business_case.clear_job!
    end
  end

  private

  def cloned_object
    clone = @object.dup
    if clone.update_attributes(clone_params)
      clone
    else
      @object
    end
  end

  def clone_params
    @params.merge(user_id: @testing_ground.user_id, public: false)
  end

  def in_use?
    TestingGround.where("`#{object_id_property}` = ?", @object.id).count > 1
  end

  def object_id_property
    @object.class.name.underscore + "_id"
  end
end

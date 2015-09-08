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
    Finance::BusinessCaseCreator.new(@testing_ground).calculate
  end

  private

  def cloned_object
    clone = @object.dup
    clone.update_attributes(clone_params)
    clone
  end

  def clone_params
    @params.merge(user_id: @testing_ground.user, public: false)
  end

  def in_use?
    TestingGround.where("`#{object_id_property}` = ?", @object.id).count > 1
  end

  def object_id_property
    @object.class.name.underscore + "_id"
  end
end

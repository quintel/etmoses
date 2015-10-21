class TestingGround::Cloner
  attr_accessor :errors

  def initialize(testing_ground, object, params)
    @testing_ground = testing_ground
    @object = object
    @params = params
  end

  def clone
    in_use? ? clone_object : update_attributes

    clear_job
  end

  def errors
    @errors ||= []
  end

  private

  def clear_job
    if @errors.nil? && @testing_ground.business_case
      @testing_ground.business_case.clear_job!
    end
  end

  def clone_object
    if cloned_object.update_attributes(clone_params)
      @testing_ground.update_attribute(object_id_property, cloned_object.id)
    else
      @errors = cloned_object.errors.full_messages
    end
  end

  def update_attributes
    unless @object.update_attributes(@params)
      @errors = @object.errors.full_messages
    end
  end

  def cloned_object
    @cloned_object ||= @object.dup
  end

  def clone_params
    @params.merge(user_id: @testing_ground.user_id,
                  name: name,
                  public: false,
                  original_id: @object.id)
  end

  def name
    "#{@object.name} - Clone ##{clone_count}"
  end

  def clone_count
    @object.class.where(original_id: @object.id).count + 1
  end

  def in_use?
    TestingGround.where("`#{object_id_property}` = ?", @object.id).count > 1
  end

  def object_id_property
    @object.class.name.underscore + "_id"
  end
end

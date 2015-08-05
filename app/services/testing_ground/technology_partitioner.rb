class TestingGround::TechnologyPartitioner
  def initialize(technology, size)
    @technology = technology
    @size = size
  end

  def partition
    div, mod = divmod

    ( Array.new(mod, duplicate_technology(div + 1)) +
      Array.new(@size - mod, duplicate_technology(div)) ).reject do |tech|
      tech['units'].zero?
    end
  end

  private

  def duplicate_technology(units)
    @technology.dup.update('units' => units)
  end

  def divmod
    @technology['units'].to_i.divmod(@size)
  end
end

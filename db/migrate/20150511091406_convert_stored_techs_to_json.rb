class ConvertStoredTechsToJson < ActiveRecord::Migration
  def up
    convert('---', YAML, JSON)
  end

  def down
    convert('[', JSON, YAML)
  end

  private

  def convert(guard, from, to)
    rows = TestingGround.connection.execute(
      'SELECT id, technologies FROM testing_grounds'
    )

    rows.each do |(id, techs)|
      if techs.start_with?(guard)
        TestingGround.where(id: id)
          .update_all(technologies: to.dump(from.load(techs)))
      end
    end
  end
end

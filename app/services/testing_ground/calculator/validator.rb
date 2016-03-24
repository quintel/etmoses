class TestingGround::Calculator
  module Validator
    def validation_error
      if invalid_technologies.any?
        I18n.t("testing_grounds.error.invalid_technologies",
            invalid_technologies: invalid_technologies.join(", "))
      end
    end

    private

    def invalid_technologies
      @testing_ground.technology_profile
        .list.values.flatten.reject(&:valid?).map do |tech|
          "'#{tech.name}' on '#{tech.node}'"
        end
    end
  end
end

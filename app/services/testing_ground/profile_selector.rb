class TestingGround
  module ProfileSelector
    ##
    ## Profile selection part
    ## Initiates a LoadProfiles::Selector object
    ##
    def profile_selector(technology)
      LoadProfiles::Selector.new(available_profiles, technology)
    end

    def available_profiles
      @available_profiles ||= TechnologyProfiles::Query
        .new(@technologies).query
    end
  end
end

module Network
  module Technologies
    # A battery represents a technology which may take in excess energy from the
    # network and release it again as needed.
    #
    # No custom behavior is needed over the base Storage class, but Battery exists
    # to more easily differentiate batteries from other technologies which also
    # inherit from the Storage class.
    class Battery < Storage
      def self.disabled?(options)
        ! options[:battery_storage]
      end
    end # Battery
  end
end

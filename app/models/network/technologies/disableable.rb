module Network
  module Technologies
    module Disableable
      # Internal: Enables implementors to customise the profile prior to
      # initializing the class which represents the disabled technology.
      def disabled_profile(profile, _options)
        profile
      end

      # Internal: Returns the technology class to be used when the technology is
      # turned off.
      def disabled_class
        Null
      end

      # Internal: When storage is disabled, returns disabled versions of each
      # storage technology.
      def build(installed, profile, options)
        if disabled?(options)
          disabled_class.new(
            installed,
            Network::Curve.from(disabled_profile(profile, options)),
            **options
          )
        else
          new(installed, profile, **options)
        end
      end

      # Public: Determines, based on the given options, if the technology should
      # be disabled when calculating the testing ground.
      def disabled?(_options)
        false
      end
    end # Disableable
  end
end

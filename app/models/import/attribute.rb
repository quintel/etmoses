class Import
  class Attribute
    PRESENT = 'present'.freeze
    FUTURE  = 'future'.freeze

    attr_reader :local_name, :remote_name

    # Public: Creates an attribute which converts ETEngine data to ETMoses data.
    #
    # local_name  - The name of the InstalledTechnology attribute to which we
    #               will write.
    # remote_name - The name of the attribute as it appears in the data sent by
    #               ETEngine.
    # extractor   - An optional block which may be used to further alter the
    #               attribute value. The block is passed the future value, the
    #               data from ETEngine, and the Attribute instance.
    #
    # Returns an Import::Attribute
    def initialize(local_name, remote_name = local_name, &extractor)
      @local_name  = local_name.freeze
      @remote_name = remote_name.freeze
      @extractor   = extractor || ->(value, *) { value }
    end

    # Public: Given data from ETEngine, extracts the value for use in ETMoses.
    #
    # Returns a numeric.
    def call(data)
      @extractor.call(future(data, @remote_name), data, self)
    end

    # Public: Given the ETE data and a key name, retrieves the present value.
    def present(data, subkey)
      extract_subkey(data, subkey, PRESENT)
    end

    # Public: Given the ETE data and a key name, retrieves the future value.
    def future(data, subkey)
      extract_subkey(data, subkey, FUTURE)
    end

    def to_s
      "#{ @remote_name } to #{ @local_name }"
    end

    def inspect
      "#<#{ self.class.name }: #{ to_s }>"
    end

    #######
    private
    #######

    def extract_subkey(data, subkey, period)
      if subkey.include?('.')
        # Deal with attributes which map to a value inside a hash. Only one-
        # hash-deep is supported.
        subkey, rest = subkey.split('.', 2)

        value     = extract_subkey(data, subkey, period)
        extracted = value.is_a?(Hash) ? value[rest] : value

        extracted || 0.0
      else
        data.key?(subkey) ? data[subkey][period] : 0.0
      end
    end
  end
end

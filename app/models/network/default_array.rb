module Network
  # An array which accepts a block which will assign a default value to each
  # element in the array upon access.
  class DefaultArray < Array
    def initialize(*args, &block)
      unless block
        fail ArgumentError, 'Must supply a block which yields default values'
      end

      super
      @default = block
    end

    def [](key)
      super || (self[key] = @default.call(key))
    end
  end
end # Network

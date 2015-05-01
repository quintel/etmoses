module Network
  # An array which accepts a block which will assign a default value to each
  # element in the array upon access.
  class DefaultArray < Array
    def initialize(*args, &block)
      super
      @default = block
    end

    def [](key)
      super || (self[key] = @default.call(key))
    end
  end
end # Network

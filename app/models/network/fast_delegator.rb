module Network
  # A simpler SimpleDelegator.
  #
  # Implements the *basics* of SimpleDelegator with much better performance.
  # Delegated methods with a known number of mandatory arguments can be defined
  # without needing to use *splat arguments.
  #
  # Since the target class is known at complile time, we can omit the "responds
  # to?" checks performed by SimpleDelegator.
  #
  # However, FastDelegator does not support methods with block arguments and
  # performance will not be so good when calling methods with default values or
  # *splats.
  module FastDelegator
    module_function

    def base_class
      Class.new do
        def initialize(object)
          @object = object
        end
      end
    end

    def create(klass)
      delegator = base_class
      methods   = klass.public_instance_methods - Object.instance_methods

      methods.each do |name|
        arity = klass.instance_method(name).arity

        if arity >= 0
          # For fasted possible delegation, when we know how many arguments the
          # method takes, we define a method with an identical signature to
          # avoid creating an array by using a *splat. This is fastest.
          arguments = arity.times.map { |count| "arg#{ count }" }.join(', ')

          delegator.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{ name }(#{ arguments })
              @object.#{ name }(#{ arguments })
            end
          RUBY
        else
          # Methods which take splat arguments, or have defaults, cannot be
          # defined with an explicit number of arguments (as above) and must use
          # *args instead. This is slower.
          delegator.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{ name }(*args)
              @object.#{ name }(*args)
            end
          RUBY
        end
      end

      delegator
    end
  end # FastDelegator
end # Network

# PerThreadRegistry from ActiveSupport 4.0

# This module is used to encapsulate access to thread local variables.
#
# Instead of polluting the thread locals namespace:
#
#   Thread.current[:connection_handler]
#
# you define a class that extends this module:
#
#   module ActiveRecord
#     class RuntimeRegistry
#       extend ActiveSupport::PerThreadRegistry
#
#       attr_accessor :connection_handler
#     end
#   end
#
# and invoke the declared instance accessors as class methods. So
#
#   ActiveRecord::RuntimeRegistry.connection_handler = connection_handler
#
# sets a connection handler local to the current thread, and
#
#   ActiveRecord::RuntimeRegistry.connection_handler
#
# returns a connection handler local to the current thread.
#
# This feature is accomplished by instantiating the class and storing the
# instance as a thread local keyed by the class name. In the example above
# a key "ActiveRecord::RuntimeRegistry" is stored in <tt>Thread.current</tt>.
# The class methods proxy to said thread local instance.
#
# If the class has an initializer, it must accept no arguments.

module PDC::Resource
  module PerThreadRegistry
    def self.extended(object)
      object.instance_variable_set '@per_thread_registry_key', object.name.freeze
    end
    def instance
      Thread.current[@per_thread_registry_key] ||= new
    end
    protected
      def method_missing(name, *args, &block) # :nodoc:
        # Caches the method definition as a singleton method of the receiver.
        #
        # By letting #delegate handle it, we avoid an enclosure that'll capture args.
        singleton_class.delegate name, to: :instance
        send(name, *args, &block)
      end
  end
end


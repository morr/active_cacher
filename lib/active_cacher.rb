require "active_cacher/version"

# Module for caching results of method invocations. It's used as follows:
#
# class A
#   prepend ActiveCacher.instance
#   instance_cache :foo_a, :foo_b
#   rails_cache :foo_c
#
#    def foo_a
#      # some code
#    end
#    def foo_b
#      # some code
#    end
#    def foo_c
#      # some code
#    end
# end
#
# Here return values of method calls 'foo_a' and 'foo_b' will be cached into
# instance variables '@_foo_a' and '@__foo_b' while result of method call 'foo_c'
# will be both cached into instance variable '@_foo_c' and written to Rails cache.
#
# Calling 'instance_cache :foo_a' is roughly equivalent to the following code:
#
# def foo_a
#   @__foo_a ||= begin
#     # some code
#   end
# end
#
# And calling 'rails_cache :foo_c' is roughly equivalent to the following code:
#
# def foo_c
#   @__foo_c ||= Rails.cache.fetch [self, :foo_c] do
#     # some code
#   end
# end

module ActiveCacher
  @cloned = false
  # It's important to prepend module's clone (obtained with 'instance' class method) instead of module itself
  # since decorated methods are defined in ActiveCacher module and prepending ActiveCacher in multiple classes
  # might result into method name clashes with unpredictable consequences.
  def self.instance
    cloned = clone
    cloned.instance_variable_set "@cloned", true
    cloned
  end

  def self.prepended target
    raise "do not prepend ActiveCacher - prepend ActiveCacher.instance instead" unless @cloned
    cacher = self

    target.send :define_singleton_method, :rails_cache do |*methods|
      methods.each do |method|
        escaped_method = method.to_s.include?('?') ? "is_#{method[0..-2]}" : method

        cacher.send :define_method, method do |*args|
          instance_variable_get("@__#{escaped_method}") ||
            instance_variable_set("@__#{escaped_method}", Rails.cache.fetch([cache_key_object, method], expires_in: 2.weeks) { prepare_for_cache(super(*args)) })
        end
      end
    end

    target.send :define_singleton_method, :instance_cache do |*methods|
      methods.each do |method|
        escaped_method = method.to_s.include?('?') ? "is_#{method[0..-2]}" : method

        cacher.send :define_method, method do |*args|
          instance_variable_get("@__#{escaped_method}") ||
            instance_variable_set("@__#{escaped_method}", prepare_for_cache(super(*args)))
        end
      end
    end
  end

private
  def cache_key_object
    defined?(Draper::Decorator) && object.kind_of?(Draper::Decorator) ? object : self
  end

  def prepare_for_cache object
    defined?(ActiveRecord::Relation) && object.kind_of?(ActiveRecord::Relation) ? object.to_a : object
  end
end

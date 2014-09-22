class MethodOverrides
  def initialize
    @overrides = {}
  end

  def empty?(method_name)
    @overrides[method_name].nil? || @overrides[method_name].empty?
  end

  def store_override(method_name, method)
    @overrides[method_name] ||= []
    @overrides[method_name] << method
  end

  def get(obj)
    OverridesInstance.new(@overrides, obj)
  end
end

class OverridesInstance
  def initialize(overrides, obj, ind = 0)
    @overrides = overrides
    @obj       = obj
    @ind       = ind
  end

  def [](ind)
    OverridesInstance.new(@overrides, @obj, @ind - ind)
  end

  def call_override(method_symbol, *args, &block)
    if @overrides.has_key?(method_symbol.to_sym)
      overrides = @overrides[method_symbol.to_sym]
      ind       = overrides.count + (@ind - 1)
      ovin      = Thread.current["overrides_ind_#{@obj.__id__}"] || 0
      ind       += ovin
      Thread.current["overrides_ind_#{@obj.__id__}"] = @ind + ovin - 1
      rv                                             = overrides[ind].bind(@obj).call(*args, &block)
      Thread.current["overrides_ind_#{@obj.__id__}"] = ovin
      rv
    else
      @obj.send(method_symbol.to_sym, *args, &block)
    end
  end

  def method_missing(symbol, *args, &block)
    call_override(symbol, *args, &block)
  end
end

class Object
  def create_method(name, &block)
    self.send(:define_method, name, &block)
  end

  def overrides
    (@overrides && @overrides.get(self)) || self.class.class_overrides(self)
  end

  def true_overrides
    @overrides
  end

  def true_overrides=(overrides)
    @overrides = overrides
  end

  def override(method_name, &block)
    s2 = self
    class << self
      self
    end.class_eval {
      original_method     = instance_method(method_name.to_sym)
      s2.true_overrides ||= MethodOverrides.new
      s2.true_overrides.store_override(method_name.to_sym, original_method)
      self.create_method(method_name.to_sym, &block)
    }
  end

  class << self
    def class_overrides(s)
      @overrides && @overrides.get(s)
    end

    def true_overrides
      @overrides
    end

    def true_overrides=(overrides)
      @overrides = overrides
    end

    def override(method_name, &block)
      self.class_eval {
        original_method     = instance_method(method_name.to_sym)
        self.true_overrides ||= MethodOverrides.new
        self.true_overrides.store_override(method_name.to_sym, original_method)
        self.create_method(method_name.to_sym, &block)
      }
    end
  end
end
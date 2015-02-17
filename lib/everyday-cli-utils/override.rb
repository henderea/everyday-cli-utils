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
    @overrides.has_key?(method_symbol.to_sym) ? -> {
      overrides, ind, ovin = get_overrides_and_inds(method_symbol)
      call_override_at_index(overrides, ind, ovin, args, &block)
    }.call : @obj.send(method_symbol.to_sym, *args, &block)
  end

  def call_override_at_index(overrides, ind, ovin, args, &block)
    Thread.current["overrides_ind_#{@obj.__id__}"] = @ind + ovin - 1
    rv                                             = overrides[ind].bind(@obj).call(*args, &block)
    Thread.current["overrides_ind_#{@obj.__id__}"] = ovin
    rv
  end

  def get_overrides_and_inds(method_symbol)
    overrides = @overrides[method_symbol.to_sym]
    ind       = overrides.count + (@ind - 1)
    ovin      = Thread.current["overrides_ind_#{@obj.__id__}"] || 0
    ind       += ovin
    return overrides, ind, ovin
  end

  def method_missing(symbol, *args, &block)
    call_override(symbol, *args, &block)
  end

  class << self
    def register_override(s, s2, method_name, &block)
      s.class_eval {
        original_method   = s.instance_method(method_name.to_sym)
        s2.true_overrides ||= MethodOverrides.new
        s2.true_overrides.store_override(method_name.to_sym, original_method)
        s.create_method(method_name.to_sym, &block)
      }
    end
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
    s = class << self
      self
    end
    OverridesInstance.register_override(s, self, method_name, &block)
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
      OverridesInstance.register_override(self, self, method_name, &block)
    end
  end
end
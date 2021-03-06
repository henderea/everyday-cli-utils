require_relative 'safe/maputil'
require 'optparse'
require 'yaml'

module EverydayCliUtils
  class Option
    class << self
      def add_option(options, opts, names, opt_name, settings = {})
        opts.on(*names) {
          options[opt_name] = !settings[:toggle] || !options[opt_name]
          yield if block_given?
        }
      end

      def add_option_with_param(options, opts, names, opt_name, settings = {})
        opts.on(*names, settings[:type] || String) { |param|
          if settings[:append]
            options[opt_name] << param
          else
            options[opt_name] = param
          end
          yield if block_given?
        }
      end
    end
  end

  class OptionType
    def initialize(default_value_block, value_determine_block, name_mod_block = nil, value_transform_block = nil)
      @default_value_block   = default_value_block
      @value_determine_block = value_determine_block
      @name_mod_block        = name_mod_block
      @value_transform_block = value_transform_block
    end

    def default_value(settings = {})
      @default_value_block.call(settings)
    end

    def updated_value(current_value, new_value, settings = {})
      new_value = @value_transform_block.call(new_value, settings) unless @value_transform_block.nil?
      @value_determine_block.call(current_value, new_value, settings)
    end

    def mod_names(names, settings = {})
      @name_mod_block.call(names, settings)
    end
  end

  class OptionTypes
    class << self
      def def_type(type, default_value_block, value_determine_block, name_mod_block = nil, value_transform_block = nil)
        @types       ||= {}
        @types[type] = OptionType.new(default_value_block, value_determine_block, name_mod_block, value_transform_block)
      end

      def default_value(type, settings = {})
        @types ||= {}
        @types.has_key?(type) ? @types[type].default_value(settings) : nil
      end

      def updated_value(type, current_value, new_value, settings = {})
        @types ||= {}
        @types.has_key?(type) ? @types[type].updated_value(current_value, new_value, settings) : current_value
      end

      def mod_names(type, names, settings = {})
        @types ||= {}
        @types.has_key?(type) ? @types[type].mod_names(names, settings) : names
      end

      #region option procs
      def option_default(_)
        false
      end

      def option_value_determine(current_value, new_value, settings)
        new_value ? (!settings[:toggle] || !current_value) : current_value
      end

      def option_name_mod(names, settings)
        settings.has_key?(:desc) ? (names + [settings[:desc]]) : names
      end

      def option_value_transform(new_value, _)
        !(!new_value)
      end

      #endregion

      def def_option_type
        def_type(:option,
                 method(:option_default),
                 method(:option_value_determine),
                 method(:option_name_mod),
                 method(:option_value_transform))
      end

      #region option_with_param procs
      def param_option_default(settings)
        settings[:append] ? [] : nil
      end

      def param_option_value_determine(current_value, new_value, settings)
        settings[:append] ? (current_value + new_value) : ((new_value.nil? || new_value == '') ? current_value : new_value)
      end

      def param_option_name_mod(names, settings)
        names[0] << ' PARAM' unless names.any? { |v| v.include?(' ') }
        names = settings.has_key?(:desc) ? (names + [settings[:desc]]) : names
        settings.has_key?(:type) ? (names + [settings[:type]]) : names
      end

      def param_option_value_transform(new_value, settings)
        new_value.is_a?(Array) ? (settings[:append] ? new_value : new_value[0]) : (settings[:append] ? [new_value] : new_value)
      end

      #endregion

      def def_option_with_param_type
        def_type(:option_with_param,
                 method(:param_option_default),
                 method(:param_option_value_determine),
                 method(:param_option_name_mod),
                 method(:param_option_value_transform))
      end
    end

    def_option_type
    def_option_with_param_type
  end

  class OptionDef
    attr_reader :value, :names

    def initialize(type, names, settings = {}, &block)
      @type     = type
      @names    = names
      @settings = settings
      @block    = block
      @value    = OptionTypes.default_value(type, settings)
      @values   = {}
    end

    def set(value)
      @value  = value
      @values = {}
    end

    def update(value, layer)
      @values[layer] = OptionTypes.default_value(@type, @settings) unless @values.has_key?(layer)
      @values[layer] = OptionTypes.updated_value(@type, @values[layer], value, @settings)
    end

    def run
      @block.call unless @block.nil? || !@block
    end

    def composite(*layers)
      value = @value
      layers.each { |layer| value = OptionTypes.updated_value(@type, value, @values[layer], @settings) if @values.has_key?(layer) }
      value
    end

    class << self
      def register(opts, options, type, opt_name, names, settings = {}, default_settings = {}, &block)
        settings          = EverydayCliUtils::MapUtil.extend_hash(default_settings, settings)
        opt               = OptionDef.new(type, names.clone, settings, &block)
        options[opt_name] = opt
        names             = OptionTypes.mod_names(type, names, settings)
        opts.on(*names) { |*args|
          opt.update(args, :arg)
          opt.run
        }
      end
    end
  end

  class SpecialOptionDef
    attr_reader :order, :settings, :names, :order
    attr_accessor :state

    def initialize(order, exit_on_action, names, print_on_exit_str, settings, action_block, pre_parse_block = nil)
      @order             = order
      @exit_on_action    = exit_on_action
      @names             = names
      @print_on_exit_str = print_on_exit_str
      @settings          = settings
      @action_block      = action_block
      @pre_parse_block   = pre_parse_block
      @state             = false
    end

    def run(options_list)
      if @state
        @action_block.call(self, options_list)
        if @exit_on_action
          puts @print_on_exit_str unless @print_on_exit_str.nil?
          exit 0
        end
      end
    end

    def run_pre_parse(options_list)
      @pre_parse_block.call(self, options_list) unless @pre_parse_block.nil?
    end

    class << self
      def register(order, opts, options, opt_name, names, exit_on_action, print_on_exit_str, settings, default_settings, action_block, pre_parse_block = nil)
        settings                          = EverydayCliUtils::MapUtil.extend_hash(default_settings, settings)
        opt                               = SpecialOptionDef.new(order, exit_on_action, names, print_on_exit_str, settings, action_block, pre_parse_block)
        options.special_options[opt_name] = opt
        names << settings[:desc] if settings.has_key?(:desc)
        opts.on(*names) { opt.state = true }
      end
    end
  end

  class OptionList
    attr_reader :opts, :special_options
    attr_accessor :default_settings, :help_str

    def initialize
      @options          = {}
      @special_options  = {}
      @default_settings = {}
      @opts             = OptionParser.new
      @help_str         = nil
    end

    def []=(opt_name, opt)
      @options[opt_name] = opt
    end

    def set(opt_name, value)
      @options[opt_name].set(value) if @options.has_key?(opt_name)
    end

    def set_all(opts)
      opts.each { |opt| set(opt[0], opt[1]) }
    end

    def update(opt_name, value, layer)
      @options[opt_name].update(value, layer) if @options.has_key?(opt_name)
    end

    def update_all(layer, opts)
      opts.each { |opt| update(opt[0], opt[1], layer) }
    end

    def register(type, opt_name, names, settings = {}, &block)
      OptionDef.register(@opts, self, type, opt_name, names, settings, @default_settings, &block)
    end

    def register_special(order, opt_name, names, exit_on_action, print_on_exit_str, settings, action_block, pre_parse_block = nil)
      SpecialOptionDef.register(order, @opts, self, opt_name, names, exit_on_action, print_on_exit_str, settings, @default_settings, action_block, pre_parse_block)
    end

    def run_special
      run_special_helper { |v| v[1].run(self) }
    end

    def run_special_pre_parse
      run_special_helper { |v| v[1].run_pre_parse(self) }
    end

    def run_special_helper(&block)
      @special_options.to_a.sort_by { |v| v[1].order }.each(&block)
    end

    def composite(*layers)
      hash = {}
      @options.each { |v| hash[v[0]] = v[1].composite(*layers) }
      hash
    end

    def help
      @help_str.nil? ? @opts.help : @help_str
    end

    def to_s
      @help_str.nil? ? @opts.to_s : @help_str
    end

    def banner=(banner)
      @opts.banner = banner
    end

    def parse!(argv = ARGV)
      @opts.parse!(argv)
    end

    def show_defaults
      script_defaults = composite
      global_defaults = composite(:global)
      local_defaults  = composite(:global, :local)
      global_diff     = EverydayCliUtils::MapUtil.hash_diff(global_defaults, script_defaults)
      local_diff      = EverydayCliUtils::MapUtil.hash_diff(local_defaults, global_defaults)
      str             = "Script Defaults:\n#{options_to_str(script_defaults)}\n"
      str << "Script + Global Defaults:\n#{options_to_str(global_diff)}\n" unless global_diff.empty?
      str << "Script + Global + Local Defaults:\n#{options_to_str(local_diff)}\n" unless local_diff.empty?
      str
    end

    def options_to_str(options, indent = 4)
      str          = ''
      max_name_len = @options.values.map { |v| v.names.join(', ').length }.max
      options.each { |v| str << build_option_str(v, indent, max_name_len) }
      str
    end

    def build_option_str(v, indent, max_name_len)
      opt       = @options[v[0]]
      val       = v[1]
      names_str = opt.names.join(', ')
      "#{' ' * indent}#{names_str}#{' ' * ((max_name_len + 4) - names_str.length)}#{val_to_str(val)}\n"
    end

    def val_to_str(val)
      if val.nil?
        'nil'
      elsif val.is_a?(TrueClass)
        'true'
      elsif val.is_a?(FalseClass)
        'false'
      elsif val.is_a?(Enumerable)
        "[#{val.map { |v| val_to_str(v) }.join(', ')}]"
      elsif val.is_a?(Numeric)
        val.to_s
      else
        "'#{val.to_s}'"
      end
    end
  end

  module OptionUtil
    def option(opt_name, names, settings = {}, &block)
      @options ||= OptionList.new
      @options.register(:option, opt_name, names, settings, &block)
    end

    def option_with_param(opt_name, names, settings = {}, &block)
      @options ||= OptionList.new
      @options.register(:option_with_param, opt_name, names, settings, &block)
    end

    def defaults_option(file_path, names, settings = {})
      defaults_options_helper(file_path, names, settings, 4, :defaults, 'Defaults set', :local)
    end

    def global_defaults_option(file_path, names, settings = {})
      defaults_options_helper(file_path, names, settings, 3, :global_defaults, 'Global defaults set', :global)
    end

    def defaults_options_helper(file_path, names, settings, order, opt_name, print_on_exit_string, composite_name)
      @options             ||= OptionList.new
      settings[:file_path] = File.expand_path(file_path)
      @options.register_special(order, opt_name, names, key_absent_or_true(settings, :exit_on_save), print_on_exit_string, settings,
                                write_defaults_proc(composite_name), read_defaults_proc(composite_name))
    end

    def write_defaults_proc(composite_name)
      ->(opt, options) { IO.write(opt.settings[:file_path], options.composite(composite_name, :arg).to_yaml) }
    end

    def read_defaults_proc(composite_name)
      ->(opt, options) {
        file_path = opt.settings[:file_path]
        options.update_all composite_name, YAML::load_file(file_path) unless file_path_nil_or_exists?(file_path)
      }
    end

    def file_path_nil_or_exists?(file_path)
      file_path.nil? || !File.exist?(file_path)
    end

    def key_absent_or_true(settings, key)
      !settings.has_key?(key) || settings[key]
    end

    def show_defaults_option(names, settings = {})
      show_info_helper(names, settings, 2, :show_defaults, :exit_on_show) { |_, options|
        puts options.show_defaults
      }
    end

    def help_option(names, settings = {})
      show_info_helper(names, settings, 1, :help, :exit_on_print) { |_, options|
        puts options.help
      }
    end

    def show_info_helper(names, settings, order, opt_name, exit_on_sym, &block)
      @options ||= OptionList.new
      @options.register_special(order, opt_name, names, key_absent_or_true(settings, exit_on_sym), nil, settings, block)
    end

    def default_settings(settings = {})
      @options                  ||= OptionList.new
      @options.default_settings = settings
    end

    def default_options(opts = {})
      @options ||= OptionList.new
      @options.set_all(opts)
    end

    def apply_options(layer, opts = {})
      @options ||= OptionList.new
      @options.update_all(layer, opts)
    end

    def banner(banner)
      @options        ||= OptionList.new
      @options.banner = banner
    end

    def opts
      @options ||= OptionList.new
      @options.opts
    end

    def options
      @options ||= OptionList.new
      @options.composite(:global, :local, :arg)
    end

    def option_list
      @options ||= OptionList.new
      @options
    end

    def help
      @options ||= OptionList.new
      @options.help
    end

    def to_s
      @options ||= OptionList.new
      @options.to_s
    end

    def help_str=(str)
      @options ||= OptionList.new
      @options.help_str = str
    end

    def parse!(argv = ARGV)
      @options ||= OptionList.new
      @options.run_special_pre_parse
      @options.parse!(argv)
      @options.run_special
    end
  end
end
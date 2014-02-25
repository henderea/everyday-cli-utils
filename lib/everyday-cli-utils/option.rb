require 'optparse'
require 'yaml'

module EverydayCliUtils
  class Option
    def self.add_option(options, opts, names, opt_name, settings = {})
      opts.on(*names) {
        options[opt_name] = !settings[:toggle] || !options[opt_name]
        yield if block_given?
      }
    end

    def self.add_option_with_param(options, opts, names, opt_name, settings = {})
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
    def self.def_type(type, default_value_block, value_determine_block, name_mod_block = nil, value_transform_block = nil)
      @types       ||= {}
      @types[type] = OptionType.new(default_value_block, value_determine_block, name_mod_block, value_transform_block)
    end

    def self.default_value(type, settings = {})
      @types ||= {}
      @types.has_key?(type) ? @types[type].default_value(settings) : nil
    end

    def self.updated_value(type, current_value, new_value, settings = {})
      @types ||= {}
      @types.has_key?(type) ? @types[type].updated_value(current_value, new_value, settings) : current_value
    end

    def self.mod_names(type, names, settings = {})
      @types ||= {}
      @types.has_key?(type) ? @types[type].mod_names(names, settings) : names
    end

    def_type(:option,
             ->(_) {
               false
             },
             ->(current_value, new_value, settings) {
               new_value ? (!settings[:toggle] || !current_value) : current_value
             },
             ->(names, settings) {
               settings.has_key?(:desc) ? (names + [settings[:desc]]) : names
             },
             ->(new_value, _) {
               !(!new_value)
             })
    def_type(:option_with_param,
             ->(settings) {
               settings[:append] ? [] : nil
             },
             ->(current_value, new_value, settings) {
               settings[:append] ? (current_value + new_value) : new_value
             },
             ->(names, settings) {
               names[0] << ' PARAM' unless names.any? { |v| v.include?(' ') }
               names = settings.has_key?(:desc) ? (names + [settings[:desc]]) : names
               settings.has_key?(:type) ? (names + [settings[:type]]) : names
             },
             ->(new_value, settings) {
               new_value.is_a?(Array) ? (settings[:append] ? new_value : new_value[0]) : (settings[:append] ? [new_value] : new_value)
             })
  end

  class OptionDef
    attr_reader :value

    def initialize(type, settings = {}, &block)
      @type     = type
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

    def self.register(opts, options, type, opt_name, names, settings = {}, default_settings = {}, &block)
      settings = settings.clone
      default_settings.each { |v| settings[v[0]] = v[1] unless settings.has_key?(v[0]) }
      opt               = OptionDef.new(type, settings, &block)
      options[opt_name] = opt
      names             = OptionTypes.mod_names(type, names, settings)
      opts.on(*names) { |*args|
        opt.update(args, :arg)
        opt.run
      }
    end
  end

  class OptionList
    attr_reader :opts
    attr_accessor :default_settings, :help_str

    def initialize
      @options          = {}
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

    def update(opt_name, value, layer)
      @options[opt_name].update(value, layer) if @options.has_key?(opt_name)
    end

    def register(type, opt_name, names, settings = {}, &block)
      OptionDef.register(@opts, @options, type, opt_name, names, settings, @default_settings, &block)
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
      @options       ||= OptionList.new
      @set_defaults  = false
      @defaults_file = File.expand_path(file_path)
      @exit_on_save  = !settings.has_key?(:exit_on_save) || settings[:exit_on_save]
      names << settings[:desc] if settings.has_key?(:desc)
      @options.opts.on(*names) { @set_defaults = true }
    end

    def global_defaults_option(file_path, names, settings = {})
      @options              ||= OptionList.new
      @set_global_defaults  = false
      @global_defaults_file = File.expand_path(file_path)
      @exit_on_global_save  = !settings.has_key?(:exit_on_save) || settings[:exit_on_save]
      names << settings[:desc] if settings.has_key?(:desc)
      @options.opts.on(*names) { @set_global_defaults = true }
    end

    def help_option(names, settings = {})
      @options       ||= OptionList.new
      @display_help  = false
      @exit_on_print = !settings.has_key?(:exit_on_print) || settings[:exit_on_print]
      names << settings[:desc] if settings.has_key?(:desc)
      @options.opts.on(*names) { @display_help = true }
    end

    def default_settings(settings = {})
      @options                  ||= OptionList.new
      @options.default_settings = settings
    end

    def default_options(opts = {})
      @options ||= OptionList.new
      opts.each { |opt| @options.set(opt[0], opt[1]) }
    end

    def apply_options(layer, opts = {})
      @options ||= OptionList.new
      opts.each { |opt| @options.update(opt[0], opt[1], layer) }
    end

    def banner(banner)
      @options        ||= OptionList.new
      @options.banner = banner
    end

    def opts
      @options.opts
    end

    def options
      @options.composite(:global, :local, :arg)
    end

    def option_list
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
      @options.help_str = str
    end

    def parse!(argv = ARGV)
      @options ||= OptionList.new
      apply_options :global, YAML::load_file(@global_defaults_file) unless @global_defaults_file.nil? || !File.exist?(@global_defaults_file)
      apply_options :local, YAML::load_file(@defaults_file) unless @defaults_file.nil? || !File.exist?(@defaults_file)
      @options.parse!(argv)
      if @display_help
        puts help
        exit 0 if @exit_on_print
      end
      if @set_global_defaults
        IO.write(@global_defaults_file, @options.composite(:global, :arg).to_yaml)
        if @exit_on_global_save
          puts 'Global defaults set'
          exit 0
        end
      elsif @set_defaults
        IO.write(@defaults_file, @options.composite(:local, :arg).to_yaml)
        if @exit_on_save
          puts 'Defaults set'
          exit 0
        end
      end
    end
  end
end
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

  module OptionUtil
    attr_reader :options, :opts

    def option(opt_name, names, settings = {})
      @opts             ||= OptionParser.new
      @options          ||= {}
      @default_settings ||= {}
      settings[:toggle] = @default_settings[:toggle] unless settings.has_key?(:toggle) || !@default_settings.has_key?(:toggle)
      names << settings[:desc] if settings.has_key?(:desc)
      @options[opt_name] = false
      @opts.on(*names) {
        @options[opt_name] = !settings[:toggle] || !@options[opt_name]
        yield if block_given?
      }
    end

    def option_with_param(opt_name, names, settings = {})
      @opts             ||= OptionParser.new
      @options          ||= {}
      @default_settings ||= {}
      settings[:append] = @default_settings[:append] unless settings.has_key?(:append) || !@default_settings.has_key?(:append)
      settings[:type]   = @default_settings[:type] unless settings.has_key?(:type) || !@default_settings.has_key?(:type)
      names[0] << ' PARAM' unless names.any? { |v| v.include?(' ') }
      names << settings[:desc] if settings.has_key?(:desc)
      @options[opt_name] = settings[:append] ? [] : nil
      @opts.on(*names, settings[:type] || String) { |param|
        settings[:append] ? @options[opt_name] << param : @options[opt_name] = param
        yield if block_given?
      }
    end

    def defaults_option(file_path, names, settings = {})
      @opts          ||= OptionParser.new
      @set_defaults  = false
      @defaults_file = File.expand_path(file_path)
      @exit_on_save  = !settings.has_key?(:exit_on_save) || settings[:exit_on_save]
      names << settings[:desc] if settings.has_key?(:desc)
      @opts.on(*names) { @set_defaults = true }
    end

    def help_option(names, settings = {})
      @opts          ||= OptionParser.new
      @display_help  = false
      @exit_on_print = !settings.has_key?(:exit_on_print) || settings[:exit_on_print]
      names << settings[:desc] if settings.has_key?(:desc)
      @opts.on(*names) { @display_help = true }
    end

    def default_settings(settings = {})
      @default_settings = settings
    end

    def default_options(opts = {})
      opts.each { |opt| @options[opt[0]] = opt[1] }
    end

    def banner(banner)
      @opts        ||= OptionParser.new
      @opts.banner = banner
    end

    def help
      @opts ||= OptionParser.new
      @opts.help
    end

    def to_s
      @opts ||= OptionParser.new
      @opts.to_s
    end

    def parse!(argv = ARGV)
      @opts ||= OptionParser.new
      default_options YAML::load_file(@defaults_file) unless @defaults_file.nil? || !File.exist?(@defaults_file)
      @opts.parse!(argv)
      if @display_help
        puts help
        exit 0 if @exit_on_print
      end
      if @set_defaults
        IO.write(@defaults_file, @options.to_yaml)
        if @exit_on_save
          puts 'Defaults set'
          exit 0
        end
      end
    end
  end
end
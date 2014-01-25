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
      @opts              ||= OptionParser.new
      @options           ||= {}
      @default_settings  ||= {}
      settings[:toggle]  = @default_settings[:toggle] unless settings.has_key?(:toggle) || !@default_settings.has_key?(:toggle)
      @options[opt_name] = false
      @opts.on(*names) {
        @options[opt_name] = !settings[:toggle] || !@options[opt_name]
        yield if block_given?
      }
    end

    def option_with_param(opt_name, names, settings = {})
      @opts              ||= OptionParser.new
      @options           ||= {}
      @default_settings  ||= {}
      settings[:append]  = @default_settings[:append] unless settings.has_key?(:append) || !@default_settings.has_key?(:append)
      settings[:type]    = @default_settings[:type] unless settings.has_key?(:type) || !@default_settings.has_key?(:type)
      @options[opt_name] = settings[:append] ? [] : nil
      @opts.on(*names, settings[:type] || String) { |param|
        if settings[:append]
          @options[opt_name] << param
        else
          @options[opt_name] = param
        end
        yield if block_given?
      }
    end

    def default_settings(settings = {})
      @default_settings = settings
    end

    def default_options(opts = {})
      opts.each { |opt| @options[opt[0]] = opt[1] }
    end

    def parse!(argv = ARGV)
      @opts.parse!(argv)
    end
  end
end
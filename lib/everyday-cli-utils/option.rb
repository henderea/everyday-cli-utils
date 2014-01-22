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
end
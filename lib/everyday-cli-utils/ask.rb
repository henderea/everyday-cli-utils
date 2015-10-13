require 'readline'

module EverydayCliUtils
  module Ask
    def self.setup_options(options)
      mapped = []
      options.each_with_index { |v, k|
        mapped << "#{k + 1}) #{v}"
      }
      mapped.join("\n")
    end

    def self.ask(question, options, &block)
      val = '-1'
      loop do
        print "#{question}\n\n#{setup_options(options)}\n\n"
        val = Readline.readline("Please enter your choice (1 - #{options.count}): ", true)
        break if !(val =~ /^\d+$/).nil? && (1..options.count).include?(val.to_i)
        print "\n\nYou must enter an integer between 1 and #{options.count}. Please try again.\n\n"
      end
      block.call(options[val.to_i - 1])
    end

    def self.ask_yn(question, options = {}, &block)
      resp = Readline.readline("#{question} ([y]es/[n]o) ", true)
      val = resp.downcase == 'yes' || resp.downcase == 'y'
      block.call(val) if !options[:only] || options[:only] == (val ? :yes : :no)
    end

    def self.ask_prefill(question, prefill)
      old_hook = Readline.pre_input_hook
      Readline.pre_input_hook =-> {
        Readline.insert_text(prefill)
        Readline.redisplay
      }
      rval = Readline.readline(question, true)
      Readline.pre_input_hook = old_hook
      rval
    end

    def self.hash_to_options(hash, extra = [])
      hash.keys + extra
    end
  end
end
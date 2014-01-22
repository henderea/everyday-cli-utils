require 'readline'

module EverydayCliUtils
  module Ask
    def self::setup_options(options)
      mapped = []
      options.each_with_index { |v, k|
        mapped << "#{k+1}) #{v.to_s}"
      }
      mapped.join("\n")
    end

    def self::ask(question, options, &block)
      val = '-1'
      while true
        print "#{question}\n\n#{setup_options(options)}\n\n"
        val = Readline.readline("Please enter your choice (1 - #{options.count}): ", true)
        if !(val =~ /^\d+$/).nil? && (1..options.count).include?(val.to_i)
          break
        end
        print "\n\nYou must enter an integer between 1 and #{options.count}. Please try again.\n\n"
      end
      block.call(options[val.to_i - 1])
    end

    def self::hash_to_options(hash, extra = [])
      hash.keys + extra
    end
  end
end
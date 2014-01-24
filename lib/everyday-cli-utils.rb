require_relative 'everyday-cli-utils/version'

module EverydayCliUtils
  AVAILABLE_MODULES = [:ask, :format, :format_safe, :histogram, :histogram_safe, :kmeans, :kmeans_safe, :maputil, :maputil_safe, :mycurses, :option]

  def import(*names)
    EverydayCliUtils.import(*names)
  end

  def self.import(*names)
    names.each { |name|
      case (name)
        when :ask
          require_relative 'everyday-cli-utils/ask'
        when :format
          require_relative 'everyday-cli-utils/format'
        when :format_safe
          require_relative 'everyday-cli-utils/safe/format'
        when :histogram
          require_relative 'everyday-cli-utils/histogram'
        when :histogram_safe
          require_relative 'everyday-cli-utils/safe/histogram'
        when :kmeans
          require_relative 'everyday-cli-utils/kmeans'
        when :kmeans_safe
          require_relative 'everyday-cli-utils/safe/kmeans'
        when :maputil
          require_relative 'everyday-cli-utils/maputil'
        when :maputil_safe
          require_relative 'everyday-cli-utils/safe/maputil'
        when :mycurses
          require_relative 'everyday-cli-utils/mycurses'
        when :option
          require_relative 'everyday-cli-utils/option'
        else
          raise "#{name.to_s} not found!"
      end
    }
  end
end

require_relative 'everyday-cli-utils/version'

module EverydayCliUtils
  AVAILABLE_MODULES  = [:ask, :format, :format_safe, :histogram, :histogram_safe, :kmeans, :kmeans_safe, :maputil, :maputil_safe, :mycurses, :option]
  MODULE_TO_RELATIVE = {
      ask:            'everyday-cli-utils/ask',
      format:         'everyday-cli-utils/format',
      format_safe:    'everyday-cli-utils/safe/format',
      histogram:      'everyday-cli-utils/histogram',
      histogram_safe: 'everyday-cli-utils/safe/histogram',
      kmeans:         'everyday-cli-utils/kmeans',
      kmeans_safe:    'everyday-cli-utils/safe/kmeans',
      maputil:        'everyday-cli-utils/maputil',
      maputil_safe:   'everyday-cli-utils/safe/maputil',
      mycurses:       'everyday-cli-utils/mycurses',
      option:         'everyday-cli-utils/option'
  }

  def import(*names)
    EverydayCliUtils.import(*names)
  end

  def self.import(*names)
    names.each { |name|
      if MODULE_TO_RELATIVE.has_key?(name)
        require_relative MODULE_TO_RELATIVE[name]
      else
        raise "#{name.to_s} not found!"
      end
    }
  end
end

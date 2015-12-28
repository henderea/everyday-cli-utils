require_relative 'safe/format'

class String
  alias :old_method_missing :method_missing
  alias :old_respond_to? :respond_to?

  def method_missing(method, *args)
    name   = method.to_s
    colors = 'black|red|green|yellow|blue|purple|cyan|white|none'
    if (name =~ /format(_bold)?(_underline)?(?:_fg_(#{colors}))?(?:_bg_(#{colors}))?/).nil?
      old_method_missing(method, *args)
    else
      EverydayCliUtils::Format::format(self, EverydayCliUtils::Format::build_string(!$1.nil?, !$2.nil?, $3.nil? ? nil : $3.to_sym, $4.nil? ? nil : $4.to_sym))
    end
  end

  def respond_to?(method, include_all = false)
    name   = method.to_s
    colors = 'black|red|green|yellow|blue|purple|cyan|white|none'
    (!(name =~ /format(_bold)?(_underline)?(?:_fg_(#{colors}))?(?:_bg_(#{colors}))?/).nil?) || old_respond_to?(method, include_all)
  end

  def format_all
    EverydayCliUtils::Format::format_all(self)
  end

  def remove_format
    EverydayCliUtils::Format::remove_format(self)
  end

  def mycenter(len, char = ' ')
    EverydayCliUtils::Format::mycenter(self, len, char)
  end
end
module EverydayCliUtils
  module Format
    def self.build_format_hash(first_chr)
      {
          :black  => "#{first_chr}0",
          :red    => "#{first_chr}1",
          :green  => "#{first_chr}2",
          :yellow => "#{first_chr}3",
          :blue   => "#{first_chr}4",
          :purple => "#{first_chr}5",
          :cyan   => "#{first_chr}6",
          :white  => "#{first_chr}7",
          :none   => nil,
      }
    end

    FORMAT_TO_CODE   = {
        :bold      => '1',
        :underline => '4',
    }
    FG_COLOR_TO_CODE = build_format_hash('3')
    BG_COLOR_TO_CODE = build_format_hash('4')

    def self::format(text, format_code)
      (format_code.nil? || format_code == '') ? text : "\e[#{format_code}m#{text}\e[0m"
    end

    def self::build_string(bold, underline, fgcolor, bgcolor)
      str      = ''
      hit      = false
      hit, str = handle_bold(bold, hit, str)
      hit, str = handle_underline(hit, str, underline)
      hit, str = handle_fg_color(fgcolor, hit, str)
      handle_bg_color(bgcolor, hit, str)
    end

    def self.handle_bold(bold, hit, str)
      if bold
        hit = true
        str = FORMAT_TO_CODE[:bold]
      end
      return hit, str
    end

    def self.handle_underline(hit, str, underline)
      if underline
        str += ';' if hit
        hit = true
        str += FORMAT_TO_CODE[:underline]
      end
      return hit, str
    end

    def self.handle_fg_color(fgcolor, hit, str)
      unless fgcolor.nil? || FG_COLOR_TO_CODE[fgcolor].nil?
        str += ';' if hit
        hit = true
        str += FG_COLOR_TO_CODE[fgcolor]
      end
      return hit, str
    end

    def self.handle_bg_color(bgcolor, hit, str)
      unless bgcolor.nil? || BG_COLOR_TO_CODE[bgcolor].nil?
        str += ';' if hit
        str += BG_COLOR_TO_CODE[bgcolor]
      end
      str
    end

    def self::parse_format(str)
      parts     = str.split(';')
      bold      = false
      underline = false
      fgcolor   = :none
      bgcolor   = :none
      parts.each { |v|
        if v == FORMAT_TO_CODE[:bold]
          bold = true
        elsif v == FORMAT_TO_CODE[:underline]
          underline = true
        elsif v[0] == '3'
          fgcolor = FG_COLOR_TO_CODE.invert[v]
        elsif v[0] == '4'
          bgcolor = BG_COLOR_TO_CODE.invert[v]
        end
      }
      return bold, underline, fgcolor, bgcolor
    end

    def self::colorize(text, fgcolor = nil, bgcolor = nil)
      self::format(text, self::build_string(false, false, fgcolor, bgcolor))
    end

    def self::bold(text, fgcolor = nil, bgcolor = nil)
      self::format(text, self::build_string(true, false, fgcolor, bgcolor))
    end

    def self::underline(text, fgcolor = nil, bgcolor = nil)
      self::format(text, self::build_string(false, true, fgcolor, bgcolor))
    end

    def self::boldunderline(text, fgcolor = nil, bgcolor = nil)
      self::format(text, self::build_string(true, true, fgcolor, bgcolor))
    end

    def self::format_all(text)
      colors    = 'bk|rd|gr|yw|bl|pu|cy|wh|no'
      color_map = { 'bk' => :black, 'rd' => :red, 'gr' => :green, 'yw' => :yellow, 'bl' => :blue, 'pu' => :purple, 'cy' => :cyan, 'wh' => :white, 'no' => :none }
      regex     = /\{(.+?)\}\((bd)?(ul)?(?:f(#{colors}))?(?:b(#{colors}))?\)/
      text.gsub(regex) { |m|
        txt       = $1
        bold      = !$2.nil?
        underline = !$3.nil?
        fg        = $4.nil? ? nil : color_map[$4]
        bg        = $5.nil? ? nil : color_map[$5]
        format(txt, build_string(bold, underline, fg, bg))
      }
    end

    def self.mycenter(str, len, char = ' ')
      tlen = str.gsub(%r{\e\[.*?m}, '').length
      return str if tlen >= len
      b = ((len - tlen) / 2.0).floor
      a = len - tlen - b
      "#{char * b}#{str}#{char * a}"
    end
  end
end
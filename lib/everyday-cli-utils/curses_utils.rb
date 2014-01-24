module EverydayCliUtils
  module CursesUtils
    COLOR_TO_CURSES = {
        :black  => Curses::COLOR_BLACK,
        :red    => Curses::COLOR_RED,
        :green  => Curses::COLOR_GREEN,
        :yellow => Curses::COLOR_YELLOW,
        :blue   => Curses::COLOR_BLUE,
        :purple => Curses::COLOR_MAGENTA,
        :cyan   => Curses::COLOR_CYAN,
        :white  => Curses::COLOR_WHITE,
        :none   => -1,
    }

    def find_color(bgcolor, fgcolor)
      @colors.find_index { |v| v[0] == (fgcolor || :none) && v[1] == (bgcolor || :none) }
    end

    def add_color(bgcolor, fgcolor)
      Curses::init_pair(@colors.count + 1, COLOR_TO_CURSES[fgcolor || :none], COLOR_TO_CURSES[bgcolor || :none])
      ind = @colors.count + 1
      @colors << [fgcolor || :none, bgcolor || :none]
      ind
    end


    private
    def handle_color(fgcolor, bgcolor)
      return 0 if (fgcolor.nil? || fgcolor == :none) && (bgcolor.nil? || bgcolor == :none)
      ind = find_color(bgcolor, fgcolor)
      ind = ind.nil? ? add_color(bgcolor, fgcolor) : ind + 1
      Curses::color_pair(ind)
    end

    def get_format(str)
      bold, underline, fgcolor, bgcolor = Format::parse_format(str)
      (bold ? Curses::A_BOLD : 0) | (underline ? Curses::A_UNDERLINE : 0) | handle_color(fgcolor, bgcolor)
    end
  end
end
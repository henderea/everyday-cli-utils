require 'curses'
require_relative 'format'

module EverydayCliUtils
  class MyCurses

    #region External
    def initialize(use_curses, linesh, linesf)
      @use_curses = use_curses
      @linesh     = linesh
      @linesf     = linesf
      @colors     = []
      @headers    = []
      @bodies     = []
      @footers    = []
      @cur_l      = 0
      @max_l      = 0
      @ch         = nil
      if @use_curses
        Curses::noecho
        Curses::init_screen
        @subpad_start = linesh
        update_subpad_size
        @padh = Curses::Pad.new(linesh, Curses::cols)
        @padb = Curses::Pad.new(Curses::lines - linesh - linesf, Curses::cols)
        @padf = Curses::Pad.new(linesf, Curses::cols)
        @padh.keypad(true)
        @padh.clear
        @padh.nodelay = true
        @padb.keypad(true)
        @padb.clear
        @padb.nodelay = true
        @padf.keypad(true)
        @padf.clear
        @padf.nodelay = true
        Curses::cbreak
        Curses::start_color
        Curses::use_default_colors
      end
    end

    def clear
      @headers = []
      @bodies  = []
      @footers = []
    end

    def myprints
      if @use_curses
        @padh.resize(@headers.count, Curses::cols)
        @padb.resize(@bodies.count, Curses::cols)
        @padf.resize(@footers.count, Curses::cols)
        @padh.clear
        @padb.clear
        @padf.clear
        @padh.setpos(0, 0)
        @padb.setpos(0, 0)
        @padf.setpos(0, 0)
        myprint(@headers.join("\n"), @padh)
        myprint(@bodies.join("\n"), @padb)
        myprint(@footers.join("\n"), @padf)
        update_max_l
        @cur_l = [@cur_l, @max_l].min
        padh_refresh
        padb_refresh
        padf_refresh
      else
        @headers.each { |v|
          puts v
        }
        @bodies.each { |v|
          puts v
        }
        @footers.each { |v|
          puts v
        }
      end
    end

    def read_ch
      @ch = @padf.getch
    end

    def clear_ch
      read_ch
      while @ch == 10 || @ch == Curses::Key::ENTER || @ch == Curses::Key::UP || @ch == Curses::Key::DOWN
        read_ch
      end
    end

    def scroll_iteration
      old_subpad_size = @subpad_size
      update_subpad_size
      update_max_l
      update_scroll(@subpad_size != old_subpad_size)
      sleep(0.05)
      read_ch
    end

    def header_live_append(str)
      @padh << str
      padh_refresh
    end

    def body_live_append(str)
      @padb << str
      padb_refresh
    end

    def footer_live_append(str)
      @padf << str
      padf_refresh
    end

    def dispose
      Curses::close_screen if @use_curses
    end

    #endregion

    #region Internal
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

    def get_format(str)
      bold, underline, fgcolor, bgcolor = Format::parse_format(str)
      (bold ? Curses::A_BOLD : 0) | (underline ? Curses::A_UNDERLINE : 0) | handle_color(fgcolor, bgcolor)
    end

    def handle_color(fgcolor, bgcolor)
      if (fgcolor.nil? || fgcolor == :none) && (bgcolor.nil? || bgcolor == :none)
        return 0
      end
      ind = @colors.find_index { |v| v[0] == (fgcolor || :none) && v[1] == (bgcolor || :none) }
      if ind.nil?
        Curses::init_pair(@colors.count + 1, COLOR_TO_CURSES[fgcolor || :none], COLOR_TO_CURSES[bgcolor || :none])
        ind = @colors.count + 1
        @colors << [fgcolor || :none, bgcolor || :none]
      else
        ind += 1
      end
      Curses::color_pair(ind)
    end

    def myputs(text, pad)
      myprint("#{text}\n", pad)
    end

    def myprint(text, pad)
      if @use_curses
        if text.include?("\e")
          pieces = text.scan(/#{"\e"}\[(.+?)m([^#{"\e"}]+?)#{"\e"}\[0m|([^#{"\e"}]+)/)
          pieces.each { |v|
            if v[2].nil?
              pad.attron(get_format(v[0])) {
                pad << v[1]
              }
            else
              pad << v[2]
            end
          }
        else
          pad << text
        end
      else
        print text
      end
    end

    def update_max_l
      @max_l = [0, @bodies.count - @subpad_size].max
    end

    def update_subpad_size
      Curses::refresh
      @subpad_size = Curses::lines - @linesh - @linesf
    end

    def padh_refresh
      @padh.refresh(0, 0, 0, 0, @subpad_start - 1, Curses::cols - 1)
    end

    def padb_refresh
      @padb.refresh(@cur_l, 0, @subpad_start, 0, @subpad_start + @subpad_size - 1, Curses::cols - 1)
    end

    def padf_refresh
      @padf.refresh(0, 0, @subpad_start + [@subpad_size, @bodies.count].min, 0, @subpad_start + [@subpad_size, @bodies.count].min + @footers.count, Curses::cols - 1)
    end

    def update_scroll(force_refresh = false)
      if @ch == Curses::Key::UP
        @cur_l = [0, @cur_l - 1].max
      elsif @ch == Curses::Key::DOWN
        @cur_l = [@max_l, @cur_l + 1].min
      end
      @cur_l = [@cur_l, @max_l].min
      if @ch == Curses::Key::UP || @ch == Curses::Key::DOWN || force_refresh
        Curses::refresh
        padh_refresh
        padb_refresh
        padf_refresh
      end
      @cur_l
    end

    #endregion

    attr_reader :ch
    attr_accessor :bodies, :headers, :footers
    private :get_format, :handle_color, :myputs, :myprint, :update_max_l, :update_subpad_size, :padh_refresh, :padb_refresh, :padf_refresh, :update_scroll
  end
end
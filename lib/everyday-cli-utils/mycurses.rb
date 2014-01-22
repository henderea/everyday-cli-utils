require 'curses'
require_relative 'format'
require_relative 'curses_utils'

module EverydayCliUtils
  class MyCurses
    include CursesUtils
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
      setup_curses(linesf, linesh) if @use_curses
    end

    def setup_curses(linesf, linesh)
      Curses::noecho
      Curses::init_screen
      @subpad_start = linesh
      update_subpad_size
      @padh = Curses::Pad.new(linesh, Curses::cols)
      @padb = Curses::Pad.new(Curses::lines - linesh - linesf, Curses::cols)
      @padf = Curses::Pad.new(linesf, Curses::cols)
      configure_curses
    end

    def configure_curses
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

    def clear
      @headers = []
      @bodies  = []
      @footers = []
    end

    def myprints
      @use_curses ? print_curses : print_normal
    end

    def print_normal
      @headers.each { |v| puts v }
      @bodies.each { |v| puts v }
      @footers.each { |v| puts v }
    end

    def print_curses
      resize_curses
      myprint(@headers.join("\n"), @padh)
      myprint(@bodies.join("\n"), @padb)
      myprint(@footers.join("\n"), @padf)
      update_max_l
      @cur_l = [@cur_l, @max_l].min
      padh_refresh
      padb_refresh
      padf_refresh
    end

    def resize_curses
      @padh.resize(@headers.count, Curses::cols)
      @padb.resize(@bodies.count, Curses::cols)
      @padf.resize(@footers.count, Curses::cols)
      @padh.clear
      @padb.clear
      @padf.clear
      @padh.setpos(0, 0)
      @padb.setpos(0, 0)
      @padf.setpos(0, 0)
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
    private :myputs, :myprint, :update_max_l, :update_subpad_size, :padh_refresh, :padb_refresh, :padf_refresh, :update_scroll
  end
end
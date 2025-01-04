# frozen_string_literal: true

# Mock implementation of Curses for testing
module MockCurses
  def self.init_screen
  end

  def self.start_color
  end

  def self.noecho
  end

  def self.curs_set(_)
  end

  def self.close_screen
  end

  def self.lines
    24
  end

  def self.cols
    80
  end

  def self.color_pair(_)
    0
  end

  def self.timeout=(_)
  end

  def self.stdscr
    @stdscr ||= MockWindow.new
  end

  class MockWindow
    def keypad(_)
    end

    def clear
    end

    def refresh
    end

    def setpos(_, _)
    end

    def addstr(_)
    end

    def attron(_)
      yield if block_given?
    end
  end

  # Color Constants
  COLOR_BLACK = 0
  COLOR_RED = 1
  COLOR_GREEN = 2
  COLOR_YELLOW = 3
  COLOR_BLUE = 4
  COLOR_MAGENTA = 5
  COLOR_CYAN = 6
  COLOR_WHITE = 7

  # Text Attributes
  A_BOLD = 1
  A_NORMAL = 0
  A_REVERSE = 2

  # Key Constants
  KEY_UP = "KEY_UP"
  KEY_DOWN = "KEY_DOWN"
end

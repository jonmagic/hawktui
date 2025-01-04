# frozen_string_literal: true

require "curses"
require "hawktui/utils/colors"
require "hawktui/streaming_table/cell"
require "hawktui/streaming_table/column"
require "hawktui/streaming_table/layout"

module Hawktui
  # Public: Streams a dynamic table to the terminal, handling user input such as
  # pausing/unpausing and quitting. Continually appends new rows at the top of the
  # table and enforces a maximum row limit.
  #
  # Examples
  #
  #   columns = [
  #     { name: :timestamp, width: 20 },
  #     { name: :message,   width: 50 },
  #   ]
  #   table = Hawktui::StreamingTable.new(columns: columns, max_rows: 1000)
  #   table.start
  #
  #   # In a separate thread or async process:
  #   table.add_row(timestamp: Time.now.to_s, message: "Hello, world!")
  #
  # WARNING: The StreamingTable must run in the main thread and table.add_row should
  # be called from a separate thread or async process. This is because the table
  # uses curses, which is not thread-safe and does not respond to user input in
  # a separate thread.

  class StreamingTable
    # Public: Create a new StreamingTable.
    #
    # columns  - An Array of Hashes or Hawktui::StreamingTable::Column objects that define the table’s
    #            columns. Each element should at least contain `:name` and `:width`.
    # max_rows - The maximum number of rows to keep in the table. Defaults to 100000.
    #
    # Examples
    #
    #   table = Hawktui::StreamingTable.new(columns: [{ name: :time, width: 10 }], max_rows: 500)
    #
    # Returns a new StreamingTable instance.
    def initialize(columns: {}, max_rows: 100_000)
      @layout = Layout.new(columns: columns)
      @max_rows = max_rows
      @rows = [] # Store rows newest-first
      @paused = false
      @input_thread = nil
      @should_exit = false
      @current_row_index = 0
      @offset = 0
      @selected_row_indices = Set.new
    end

    # Public accessors
    attr_reader :layout, :max_rows, :rows, :paused, :selected_row_indices, :should_exit
    attr_accessor :current_row_index, :offset, :win

    # Public: Set the layout for the table. This will redraw the table with the new layout.
    #
    # new_layout - A Hawktui::StreamingTable::Layout object.
    #
    # Examples
    #
    #   new_layout = Hawktui::StreamingTable::Layout.new(columns: [{ name: :id, width: 10 }])
    #   table.layout = new_layout
    #
    # Returns nothing.
    def layout=(new_layout)
      @layout = new_layout
      draw if win # Ensure the window is initialized before attempting to draw
    end

    # Public: Start the table UI. Initializes curses, sets up input handling,
    # and draws the initial screen.
    #
    # Examples
    #
    #   table.start
    #
    # Returns nothing.
    def start
      setup
      start_input_handling
      draw
    end

    # Public: Stop the table UI. Stops the input thread, closes the curses screen,
    # and exits the process.
    #
    # Examples
    #
    #   table.stop
    #
    # Returns nothing. Exits the process.
    def stop
      @input_thread&.exit
      Curses.close_screen if win
      self.win = nil
      Process.exit(0)
    end

    # Public: Add a new row of data to the top of the table. If the table has
    # reached its maximum row limit, the oldest row is dropped.
    #
    # row_data - A Hash of row data where keys match column names. Values can be
    #            raw (String, Integer, etc.) or a Hash with :value and :color.
    #
    # Examples
    #
    #   table.add_row(timestamp: "2025-01-01 12:00", message: { value: "New Year!", color: :red })
    #
    # Returns nothing.
    def add_row(row_data)
      return unless win

      rows.unshift(row_data)
      rows.pop if rows.size > max_rows
      draw unless paused
    end

    # Internal: Set up curses, initialize colors, etc. Called by #start.
    #
    # Returns nothing.
    def setup
      Curses.init_screen
      Utils::Colors.setup_colors
      Curses.start_color
      Curses.noecho
      Curses.curs_set(0)
      Curses.stdscr.keypad(true)
      Curses.timeout = 0

      self.win = Curses.stdscr
      win.clear
    end

    # Internal: Start a separate thread to handle user input (non-blocking).
    #
    # Returns nothing.
    def start_input_handling
      @input_thread = Thread.new do
        loop do
          handle_input
          sleep 0.1
          break if should_exit
        end
      rescue => e
        win.setpos(0, 0)
        win.addstr("Error in input thread: #{e.message}")
        win.refresh
      end
    end

    # Internal: Handle user input from the terminal.
    # - 'p' to pause/unpause the table
    # - 'q' to quit the process
    # - Up/Down arrow keys to navigate the table
    # - Space to toggle selection of the current row
    #
    # Returns nothing.
    def handle_input
      case Curses.getch
      when "p"
        toggle_pause
      when "q"
        @should_exit = true
        stop
      when Curses::KEY_UP
        navigate_up
      when Curses::KEY_DOWN
        navigate_down
      when " "  # Press space to toggle selection of the current row
        toggle_selection
      end
    end

    # Internal: Navigate up one row in the table.
    #
    # Returns nothing.
    def navigate_up
      return if current_row_index <= 0

      self.current_row_index -= 1
      adjust_offset
      draw
    end

    # Internal: Navigate down one row in the table.
    #
    # Returns nothing.
    def navigate_down
      return if current_row_index >= rows.size - 1

      self.current_row_index += 1
      adjust_offset
      draw
    end

    # Internal: Adjust the offset to keep the current row in view.
    #
    # Returns nothing.
    def adjust_offset
      if current_row_index < offset
        self.offset = current_row_index
      elsif current_row_index >= offset + Curses.lines
        self.offset = current_row_index - Curses.lines + 1
      end
    end

    # Internal: Toggle whether the current row is selected.
    #
    # Returns nothing.
    def toggle_selection
      if selected_row_indices.include?(current_row_index)
        selected_row_indices.delete(current_row_index)
      else
        selected_row_indices.add(current_row_index)
      end
      draw
    end

    # Internal: Toggle whether the table is paused. When paused, new rows
    # are still collected but not rendered until unpaused.
    #
    # Returns nothing.
    def toggle_pause
      @paused = !paused
      draw_footer
    end

    # Internal: Draw the entire table (header, rows, status line).
    #
    # Returns nothing.
    def draw
      return unless win

      win.clear
      draw_header
      draw_body
      draw_footer
      win.refresh
    end

    # Internal: Draw the header row of the table.
    #
    # Returns nothing.
    def draw_header
      header_cells = layout.build_header_row
      formatted_header_cells = header_cells.zip(layout.columns).map do |cell, column|
        column.format_cell(cell)
      end
      win.attron(Curses::A_BOLD) { draw_row(0, formatted_header_cells) }
    end

    # Internal: Draw the body of the table, including all rows.
    # - Highlights the current row if it is in view.
    # - Handles scrolling if the current row is not in view.
    #
    # Returns nothing.
    def draw_body
      max_display_rows = Curses.lines - 2
      display_rows = rows[offset, max_display_rows] || []

      display_rows.each_with_index do |row_data, idx|
        row_index = offset + idx
        cells = @layout.build_cells_for_row(row_data)
        formatted_cells = cells.zip(@layout.columns).map do |cell, column|
          column.format_cell(cell)
        end

        # Decide highlight style:
        style = if row_index == current_row_index && selected_row_indices.include?(row_index)
          # Both selected + current
          Curses::A_BOLD | Curses::A_REVERSE
        elsif row_index == current_row_index
          # Current row only
          Curses::A_REVERSE
        elsif selected_row_indices.include?(row_index)
          # Selected only
          Curses::A_BOLD
        else
          nil
        end

        if style
          @win.attron(style) { draw_row(idx + 1, formatted_cells) }
        else
          draw_row(idx + 1, formatted_cells)
        end
      end
    end

    # Internal: Draw the status line at the bottom of the screen.
    #
    # Returns nothing.
    def draw_footer
      return unless win

      win.setpos(Curses.lines - 1, 0)
      status = paused ? "PAUSED" : "RUNNING"
      selection_info = " | #{@selected_row_indices.size} rows selected"
      help_text = " | Press 'p' to pause/unpause, space to select, 'q' to quit"
      win.addstr("Status: #{status}#{selection_info}#{help_text}".ljust(Curses.cols))
      win.refresh
    end

    # Internal: Draw a single row of the table, given already-formatted cells.
    #
    # y_pos           - The Integer row position (0-based) on the screen to draw.
    # formatted_cells - An Array of either:
    #                   - [string_value, color] pairs for simple cells
    #                   - Array of [string_value, color] pairs for composite cells
    #
    # Returns nothing.
    def draw_row(y_pos, formatted_cells)
      x_pos = 0
      formatted_cells.each do |cell_data|
        win.setpos(y_pos, x_pos)

        if cell_data.is_a?(Array) && cell_data[0].is_a?(Array)
          # Handle composite cell (array of [value, color] pairs)
          cell_data.each do |str_value, color|
            draw_cell_part(str_value, color)
            x_pos += str_value.to_s.length
          end
        else
          # Handle simple cell (single [value, color] pair)
          str_value, color = cell_data
          draw_cell_part(str_value, color)
          x_pos += str_value.to_s.length
        end

        # Add space between columns
        x_pos += 1
      end
    end

    # Internal: Draw a single part of a cell with the specified color.
    #
    # str_value - The String text to draw.
    # color     - An Integer color pair index or Symbol referencing a base color.
    #
    # Returns nothing.
    def draw_cell_part(str_value, color)
      return unless str_value

      if color
        color_pair = color.is_a?(Integer) ? color : Utils::Colors::BASE_COLORS[color.to_sym]&.first
        if color_pair
          win.attron(Curses.color_pair(color_pair + 1)) { win.addstr(str_value.to_s) }
        else
          win.addstr(str_value.to_s)
        end
      else
        win.addstr(str_value.to_s)
      end
    end

    # Internal: Add a string to the screen, optionally with a color attribute.
    #
    # str_value - The String text to draw.
    # color     - An Integer color index or Symbol referencing a base color in Colors.
    #
    # Returns nothing.
    def draw_with_color(str_value, color)
      if color
        color_index =
          case color
          when Integer
            color
          when Symbol, String
            Utils::Colors::BASE_COLORS[color.to_sym]&.first
          end

        if color_index
          win.attron(Curses.color_pair(color_index + 1)) { win.addstr(str_value) }
        else
          win.addstr(str_value)
        end
      else
        win.addstr(str_value)
      end
    end
  end
end

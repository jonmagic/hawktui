# frozen_string_literal: true

module Hawktui
  class StreamingTable
    # Public: A class to layout tables with columns and rows. Knows how to convert
    # a hash of row data into an array of Cell objects in the correct column order,
    # and can also build a header row for the table.
    #
    # Examples
    #
    #   columns = [
    #     { name: :timestamp, width: 20 },
    #     { name: :message,   width: 50 },
    #   ]
    #   layout = Tui::TableLayout.new(columns: columns, header_color: :white)
    #
    #   header_cells = layout.build_header_row   # => [Cell(...), Cell(...)]
    #
    class Layout
      attr_reader :columns

      # Public: Create a new TableLayout.
      #
      # columns      - An Array of Hashes or Tui::Column objects. Each element must
      #                have a `:name` and `:width`.
      # header_color - A Symbol representing the color used in the header (defaults to :white).
      #
      # Examples
      #
      #   layout = Tui::TableLayout.new(
      #     columns: [
      #       { name: :time, width: 10 },
      #       { name: :level, width: 5 },
      #     ],
      #     header_color: :yellow,
      #   )
      #
      # Returns a new TableLayout instance.
      def initialize(columns:, header_color: :white)
        @columns = columns.map do |col|
          # Accept either raw Hashes or Column objects
          col.is_a?(Column) ? col : Column.new(**col)
        end
        @header_color = header_color
      end

      # Public: Return an Array of Cell objects for the header row.
      # Uses a header-specific color if desired.
      #
      # Examples
      #
      #   layout.build_header_row
      #   # => [Cell(value="time", color=:white), Cell(value="level", color=:white)]
      #
      # Returns an Array of Tui::Cell objects.
      def build_header_row
        columns.map do |col|
          # Use the stored @header_color for all headers
          Cell.new(value: col.name, color: @header_color)
        end
      end

      # Public: Convert a single row of data (a Hash) into an array of Cells, in column order.
      #
      # row_hash - A Hash whose keys are the column names and whose values may be raw
      #            or a Hash with :value and :color.
      #
      # Examples
      #
      #   row_hash = { time: "12:00", level: { value: "INFO", color: :green } }
      #   layout.build_cells_for_row(row_hash)
      #   # => [Cell(value="12:00", color=nil), Cell(value="INFO", color=:green)]
      #
      # Returns an Array of Tui::Cell objects.
      def build_cells_for_row(row_hash)
        columns.map do |col|
          value_or_hash = row_hash[col.name] || ""
          Cell.new(value_or_hash)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Hawktui
  class StreamingTable
    # Public: Represents a single column in a table. Knows how to truncate or
    # pad a cell’s text to fit within its width.
    #
    # Examples
    #
    #   column = Hawktui::StreamingTable::Column.new(name: :message, width: 50)
    #
    class Column
      attr_reader :name, :width

      # Public: Create a new Column with a name and width.
      #
      # name  - A Symbol or String representing the column's name.
      # width - An Integer specifying how wide the column is.
      #
      # Examples
      #
      #   column = Hawktui::StreamingTable::Column.new(name: :message, width: 50)
      #
      # Returns a new Column instance.
      def initialize(name:, width:)
        @name = name
        @width = width
      end

      # Public: Format a cell value to fit within the column's width.
      #
      # Examples
      #
      #   column = Hawktui::StreamingTable::Column.new(name: :message, width: 10)
      #   cell = Hawktui::StreamingTable::Cell.new("A long message")
      #   column.format_cell(cell)
      #   # => ["A long me…", nil]
      #
      # cell - A Cell object containing the value and optional color to format.
      #
      # Returns an Array of [formatted_value, color] tuples:
      #   - For simple cells: returns a single tuple [String, Symbol/Integer]
      #   - For composite cells: returns an Array of such tuples
      def format_cell(cell)
        if cell.composite?
          # For composite cells, each component maintains its own color
          cell.components.map do |component|
            # Don't pad individual components of a composite cell
            [component.value.to_s, component.color]
          end
        else
          # For single cells, pad the entire value
          formatted_value = format_value(cell.value)
          [formatted_value, cell.color]
        end
      end

      # Internal: Format a single value to fit within the column width.
      #
      # value - The value to format (converted to String).
      #
      # Returns a String padded or truncated to fit the column width.
      def format_value(value)
        str_value = value.to_s
        if str_value.length >= width
          str_value[0...width]
        else
          str_value.ljust(width)
        end
      end
    end
  end
end

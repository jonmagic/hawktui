# frozen_string_literal: true

module Hawktui
  class StreamingTable
    # Public: Represents a single column in a table. Knows how to truncate or
    # pad a cell’s text to fit within its width.
    #
    # Examples
    #
    #   column = Tui::Column.new(name: :message, width: 50)
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
      #   column = Tui::Column.new(name: :message, width: 50)
      #
      # Returns a new Column instance.
      def initialize(name:, width:)
        @name = name
        @width = width
      end

      # Public: Format the cell’s textual value to fit within the column width.
      # If the text is longer than `width`, it will be truncated with an ellipsis ("…").
      # Otherwise, it’s left-padded with spaces to fill the width.
      #
      # cell - A Tui::Cell containing the raw value and color.
      #
      # Examples
      #
      #   cell = Tui::Cell.new("Some message")
      #   column.format_cell(cell)
      #   # => ["Some message        ", nil] # => example if width is bigger
      #
      # Returns an Array [formatted_string, color].
      def format_cell(cell)
        str_value = cell.value.to_s
        if str_value.size > width
          [str_value[0...width - 1] + "…", cell.color]
        else
          [str_value.ljust(width), cell.color]
        end
      end
    end
  end
end

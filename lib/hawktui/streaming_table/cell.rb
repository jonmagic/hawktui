# frozen_string_literal: true

module Hawktui
  class StreamingTable
    # Public: Represents a single cell in a table. Holds the cell’s value and
    # optional color, and can return both in a consistent format.
    #
    # Examples
    #
    #   cell = Tui::Cell.new("Hello")
    #   cell.value  # => "Hello"
    #   cell.color  # => nil
    #
    #   colored_cell = Tui::Cell.new(value: "Error", color: :red)
    #   colored_cell.value  # => "Error"
    #   colored_cell.color  # => :red
    #
    class Cell
      attr_reader :value, :color

      # Public: Create a new Cell object from either a raw value or a Hash with
      # `:value` and `:color` keys.
      #
      # value_or_hash - A raw value (e.g., String, Integer) or a Hash of the form:
      #                 { value: <String/Integer>, color: <Symbol/Integer> }.
      #
      # Examples
      #
      #   Cell.new("Hello")
      #   Cell.new(value: "Hello", color: :blue)
      #
      # Returns a new Cell instance.
      def initialize(value_or_hash)
        @value, @color = extract_value_and_color(value_or_hash)
      end

      # Internal: Extract the cell's value and color from the given parameter.
      #           If value_or_hash is a Hash, expects :value and :color keys.
      #
      # value_or_hash - A raw value or a Hash with :value and :color.
      #
      # Returns an Array [value, color].
      def extract_value_and_color(value_or_hash)
        case value_or_hash
        when Hash
          [value_or_hash[:value], value_or_hash[:color]]
        else
          [value_or_hash, nil]
        end
      end
    end
  end
end

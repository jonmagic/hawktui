# frozen_string_literal: true

module Hawktui
  class StreamingTable
    # Public: Represents a single cell or group of cells in a table. Can hold either
    # a single value with optional color, or an array of values/cells each with their
    # own optional colors.
    #
    # Examples
    #
    #   # Single value
    #   cell = Hawktui::StreamingTable::Cell.new("Hello")
    #   cell.value  # => "Hello"
    #   cell.color  # => nil
    #
    #   # Single cell with value and color set
    #   cell = Hawktui::StreamingTable::Cell.new(value: "Error", color: :red)
    #   cell.value  # => "Error"
    #   cell.color  # => :red
    #
    #   # Array of values with different colors
    #   multi_cell = Hawktui::StreamingTable::Cell.new([
    #     { value: "00", color: :dark_grey },
    #     { value: "42", color: :light_grey }
    #   ])
    #   multi_cell.components  # => [<Cell>, <Cell>]
    #
    class Cell
      attr_reader :value, :color, :components

      # Public: Create a new Cell object from either a raw value, a Hash with
      # `:value` and `:color` keys, or an Array of such values/hashes.
      #
      # value_or_hash_or_array - A raw value (e.g., String, Integer),
      #                          a Hash of the form { value: <String/Integer>, color: <Symbol/Integer> },
      #                          or an Array of such values/hashes.
      #
      # Examples
      #
      #   Cell.new("Hello")
      #   Cell.new(value: "Hello", color: :blue)
      #   Cell.new([{ value: "00", color: :dark_grey }, { value: "42", color: :light_grey }])
      #
      # Returns a new Cell instance.
      def initialize(value_or_hash_or_array)
        if value_or_hash_or_array.is_a?(Array)
          @components = value_or_hash_or_array.map { |v| Cell.new(v) }
          @value = @components.map(&:value).join
          @color = nil
        else
          @value, @color = extract_value_and_color(value_or_hash_or_array)
          @components = nil
        end
      end

      # Public: Check if this cell contains multiple components.
      #
      # Returns a Boolean.
      def composite?
        !components.nil?
      end

      # Internal: Extract the cell's value and color from the given parameter.
      #
      # If value_or_hash is a Hash, expects :value and :color keys.
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

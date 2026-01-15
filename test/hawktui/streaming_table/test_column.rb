# frozen_string_literal: true

require "test_helper"
require "hawktui/streaming_table/column"

describe Hawktui::StreamingTable::Column do
  describe "initialization" do
    it "initializes with a name and width" do
      column = Hawktui::StreamingTable::Column.new(name: :message, width: 50)
      assert_equal :message, column.name
      assert_equal 50, column.width
    end
  end

  describe "#format_cell" do
    let(:column) { Hawktui::StreamingTable::Column.new(name: :message, width: 10) }

    it "formats the cell value by truncating if it exceeds the column width" do
      cell = Hawktui::StreamingTable::Cell.new("Hello World!")
      formatted_value, color = column.format_cell(cell)
      assert_equal "Hello Worl", formatted_value
      assert_nil color
    end

    it "formats the cell value by padding with spaces if it is shorter than the column width" do
      cell = Hawktui::StreamingTable::Cell.new("Hello")
      formatted_value, color = column.format_cell(cell)
      assert_equal "Hello     ", formatted_value
      assert_nil color
    end

    it "preserves the cell color when formatting" do
      cell = Hawktui::StreamingTable::Cell.new(value: "Hello", color: :red)
      formatted_value, color = column.format_cell(cell)
      assert_equal "Hello     ", formatted_value
      assert_equal :red, color
    end

    it "handles an empty string as the cell value" do
      cell = Hawktui::StreamingTable::Cell.new("")
      formatted_value, color = column.format_cell(cell)
      assert_equal " " * 10, formatted_value
      assert_nil color
    end

    it "handles non-string values in the cell" do
      cell = Hawktui::StreamingTable::Cell.new(42)
      formatted_value, color = column.format_cell(cell)
      assert_equal "42        ", formatted_value
      assert_nil color
    end

    it "handles composite cells with multiple value/color tuples" do
      cell = Hawktui::StreamingTable::Cell.new([
        {value: "00", color: :dark_grey},
        {value: "42", color: :light_grey}
      ])
      result = column.format_cell(cell)

      assert_kind_of Array, result
      assert_equal 2, result.size

      value1, color1 = result[0]
      value2, color2 = result[1]

      assert_equal "00", value1
      assert_equal :dark_grey, color1
      assert_equal "42", value2
      assert_equal :light_grey, color2
    end

    it "preserves colors in composite cells" do
      cell = Hawktui::StreamingTable::Cell.new([
        "plain",
        {value: "fancy", color: :blue}
      ])
      result = column.format_cell(cell)

      assert_equal 2, result.size
      assert_equal ["plain", nil], result[0]
      assert_equal ["fancy", :blue], result[1]
    end
  end
end

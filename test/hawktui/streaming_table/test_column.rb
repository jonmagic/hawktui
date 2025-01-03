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
      cell = Hawktui::StreamingTable::Cell.new("A long message")
      formatted_value, color = column.format_cell(cell)
      assert_equal "A long me…", formatted_value
      assert_nil color
    end

    it "formats the cell value by padding with spaces if it is shorter than the column width" do
      cell = Hawktui::StreamingTable::Cell.new("Short")
      formatted_value, color = column.format_cell(cell)
      assert_equal "Short     ", formatted_value
      assert_nil color
    end

    it "preserves the cell color when formatting" do
      cell = Hawktui::StreamingTable::Cell.new(value: "Content", color: :green)
      formatted_value, color = column.format_cell(cell)
      assert_equal "Content   ", formatted_value
      assert_equal :green, color
    end

    it "handles an empty string as the cell value" do
      cell = Hawktui::StreamingTable::Cell.new("")
      formatted_value, color = column.format_cell(cell)
      assert_equal "          ", formatted_value
      assert_nil color
    end

    it "handles non-string values in the cell" do
      cell = Hawktui::StreamingTable::Cell.new(12345)
      formatted_value, color = column.format_cell(cell)
      assert_equal "12345     ", formatted_value
      assert_nil color
    end
  end
end

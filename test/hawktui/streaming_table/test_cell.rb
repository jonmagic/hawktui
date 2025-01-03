# frozen_string_literal: true

require "test_helper"
require "hawktui/streaming_table/cell"

describe Hawktui::StreamingTable::Cell do
  describe "initialization" do
    it "initializes with a raw value and no color" do
      cell = Hawktui::StreamingTable::Cell.new("Hello")
      assert_equal "Hello", cell.value
      assert_nil cell.color
    end

    it "initializes with a value and color from a hash" do
      cell = Hawktui::StreamingTable::Cell.new(value: "Error", color: :red)
      assert_equal "Error", cell.value
      assert_equal :red, cell.color
    end

    it "handles a hash with only a value" do
      cell = Hawktui::StreamingTable::Cell.new(value: "Info")
      assert_equal "Info", cell.value
      assert_nil cell.color
    end
  end

  describe "#extract_value_and_color" do
    it "extracts value and color from a hash" do
      cell = Hawktui::StreamingTable::Cell.new(value: "Warning", color: :yellow)
      value, color = cell.extract_value_and_color(value: "Warning", color: :yellow)
      assert_equal "Warning", value
      assert_equal :yellow, color
    end

    it "extracts value with nil color from a raw value" do
      cell = Hawktui::StreamingTable::Cell.new("Success")
      value, color = cell.extract_value_and_color("Success")
      assert_equal "Success", value
      assert_nil color
    end
  end
end

# frozen_string_literal: true

require "test_helper"
require "hawktui/streaming_table/layout"

describe Hawktui::StreamingTable::Layout do
  describe "initialization" do
    it "initializes with an array of column hashes" do
      columns = [
        {name: :time, width: 10},
        {name: :level, width: 5}
      ]
      layout = Hawktui::StreamingTable::Layout.new(columns: columns)
      assert_equal 2, layout.columns.size
      assert_equal :time, layout.columns[0].name
      assert_equal 10, layout.columns[0].width
      assert_equal :level, layout.columns[1].name
      assert_equal 5, layout.columns[1].width
    end

    it "accepts an array of Column objects" do
      columns = [
        Hawktui::StreamingTable::Column.new(name: :message, width: 50),
        Hawktui::StreamingTable::Column.new(name: :timestamp, width: 20)
      ]
      layout = Hawktui::StreamingTable::Layout.new(columns: columns)
      assert_equal 2, layout.columns.size
      assert_equal :message, layout.columns[0].name
      assert_equal 50, layout.columns[0].width
      assert_equal :timestamp, layout.columns[1].name
      assert_equal 20, layout.columns[1].width
    end
  end

  describe "#build_header_row" do
    it "builds a header row with the correct column names and default color" do
      columns = [
        {name: :time, width: 10},
        {name: :level, width: 5}
      ]
      layout = Hawktui::StreamingTable::Layout.new(columns: columns)
      header_row = layout.build_header_row
      assert_equal 2, header_row.size
      assert_equal :time, header_row[0].value
      assert_equal :white, header_row[0].color
      assert_equal :level, header_row[1].value
      assert_equal :white, header_row[1].color
    end

    it "uses a custom header color when specified" do
      columns = [{name: :message, width: 50}]
      layout = Hawktui::StreamingTable::Layout.new(columns: columns, header_color: :yellow)
      header_row = layout.build_header_row
      assert_equal 1, header_row.size
      assert_equal :message, header_row[0].value
      assert_equal :yellow, header_row[0].color
    end
  end

  describe "#build_cells_for_row" do
    it "builds cells for a row with raw values" do
      columns = [
        {name: :time, width: 10},
        {name: :level, width: 5}
      ]
      layout = Hawktui::StreamingTable::Layout.new(columns: columns)
      row_hash = {time: "12:00", level: "INFO"}
      row_cells = layout.build_cells_for_row(row_hash)
      assert_equal 2, row_cells.size
      assert_equal "12:00", row_cells[0].value
      assert_nil row_cells[0].color
      assert_equal "INFO", row_cells[1].value
      assert_nil row_cells[1].color
    end

    it "builds cells for a row with values and colors" do
      columns = [{name: :status, width: 20}]
      layout = Hawktui::StreamingTable::Layout.new(columns: columns)
      row_hash = {status: {value: "OK", color: :green}}
      row_cells = layout.build_cells_for_row(row_hash)
      assert_equal 1, row_cells.size
      assert_equal "OK", row_cells[0].value
      assert_equal :green, row_cells[0].color
    end

    it "fills missing columns with empty strings" do
      columns = [{name: :message, width: 30}]
      layout = Hawktui::StreamingTable::Layout.new(columns: columns)
      row_hash = {}
      row_cells = layout.build_cells_for_row(row_hash)
      assert_equal 1, row_cells.size
      assert_equal "", row_cells[0].value
      assert_nil row_cells[0].color
    end
  end
end

# frozen_string_literal: true

require "test_helper"
require "curses"
require "hawktui/streaming_table"

describe Hawktui::StreamingTable do
  let(:columns) { [{name: :timestamp, width: 20}, {name: :message, width: 50}] }
  let(:max_rows) { 100 }
  let(:table) { Hawktui::StreamingTable.new(columns: columns, max_rows: max_rows) }

  before do
    Curses.stubs(:init_screen)
    Curses.stubs(:start_color)
    Curses.stubs(:noecho)
    Curses.stubs(:curs_set)
    Curses.stdscr.stubs(:keypad)
    Curses.stubs(:lines).returns(24)
    Curses.stubs(:cols).returns(80)
    Curses.stubs(:close_screen)

    mock_window = mock("Curses::Window")
    mock_window.stubs(:clear)
    mock_window.stubs(:setpos)
    mock_window.stubs(:addstr)
    mock_window.stubs(:attron).yields
    mock_window.stubs(:refresh)
    table.win = mock_window
  end

  describe "#initialize" do
    it "initializes with columns and max_rows" do
      assert_equal columns, table.layout.columns.map { |col| {name: col.name, width: col.width} }
      assert_equal max_rows, table.max_rows
      assert_equal [], table.rows
      refute_nil table.win
      refute table.paused
      refute table.should_exit
    end
  end

  describe "#add_row" do
    it "adds a new row to the table" do
      row = {timestamp: "2025-01-01 12:00", message: "Hello"}
      table.add_row(row)
      assert_equal [row], table.rows
    end

    it "enforces max row limit" do
      (max_rows + 1).times { |i| table.add_row({timestamp: i.to_s, message: "Test"}) }
      assert_equal max_rows, table.rows.size
      assert_equal "1", table.rows.last[:timestamp]
    end
  end

  describe "#start" do
    it "sets up and starts input handling and draws the table" do
      table.expects(:setup).once
      table.expects(:start_input_handling).once
      table.expects(:draw).once
      table.start
    end
  end

  describe "#stop" do
    it "stops input handling and exits the process" do
      thread_mock = mock
      thread_mock.expects(:exit).once
      table.instance_variable_set(:@input_thread, thread_mock)
      Curses.expects(:close_screen).once
      Process.expects(:exit).with(0).once
      table.stop
    end
  end

  describe "#toggle_pause" do
    it "toggles the pause state and redraws footer" do
      table.expects(:draw_footer).twice
      refute table.paused
      table.toggle_pause
      assert table.paused
      table.toggle_pause
      refute table.paused
    end
  end

  describe "#handle_input" do
    it 'toggles pause when "p" is pressed' do
      Curses.stubs(:getch).returns("p")
      table.expects(:toggle_pause).once
      table.handle_input
    end

    it 'exits when "q" is pressed' do
      Curses.stubs(:getch).returns("q")
      table.expects(:stop).once
      table.handle_input
    end
  end
end

# frozen_string_literal: true

require "test_helper"
require "hawktui/streaming_table"
require_relative "../support/mock_curses"

# Replace Curses with our mock version for all tests
Object.send(:remove_const, :Curses) if Object.const_defined?(:Curses)
Curses = MockCurses

describe Hawktui::StreamingTable do
  let(:columns) { [{name: :timestamp, width: 20}, {name: :message, width: 50}] }
  let(:max_rows) { 100 }
  let(:new_columns) { [{name: :id, width: 10}, {name: :message, width: 60}] }
  let(:table) { Hawktui::StreamingTable.new(columns: columns, max_rows: max_rows) }

  before do
    @mock_window = mock("MockCurses::Window")
    @mock_window.stubs(:clear)
    @mock_window.stubs(:setpos)
    @mock_window.stubs(:addstr)
    @mock_window.stubs(:attron).yields
    @mock_window.stubs(:refresh)
    table.win = @mock_window
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

    it "uses default columns when none are provided" do
      default_table = Hawktui::StreamingTable.new
      assert_equal [], default_table.layout.columns # Assuming the default is an empty array
      assert_equal 100_000, default_table.max_rows
      assert_equal [], default_table.rows
    end
  end

  describe "layout attribute" do
    it "allows reading and writing of layout" do
      new_layout = Hawktui::StreamingTable::Layout.new(columns: new_columns)
      table.layout = new_layout
      assert_equal new_columns, table.layout.columns.map { |col| {name: col.name, width: col.width} }
    end

    it "redraws the table when layout is updated" do
      new_layout = Hawktui::StreamingTable::Layout.new(columns: new_columns)
      table.expects(:draw).once
      table.layout = new_layout
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

    it "handles composite cells with multiple colors" do
      row = {
        timestamp: Time.now.to_s,
        id: [
          {value: "000", color: :dark_grey},
          {value: "42", color: :light_grey}
        ]
      }
      table.add_row(row)
      assert_equal [row], table.rows
    end

    it "handles composite cells with multiple colors" do
      row = {
        timestamp: Time.now.to_s,
        id: [
          {value: "000", color: :dark_grey},
          {value: "42", color: :light_grey}
        ]
      }
      table.add_row(row)
      assert_equal [row], table.rows
    end
  end

  describe "#draw_row" do
    it "draws composite cells with multiple colors" do
      sequence = sequence("drawing")

      @mock_window.expects(:setpos).with(1, 0).in_sequence(sequence)
      @mock_window.expects(:addstr).with("000").in_sequence(sequence)
      @mock_window.expects(:addstr).with("42").in_sequence(sequence)
      @mock_window.expects(:setpos).with(1, 6).in_sequence(sequence)
      @mock_window.expects(:addstr).with("Message").in_sequence(sequence)

      formatted_cells = [
        [
          ["000", 1],
          ["42", 2]
        ],
        ["Message", nil]
      ]

      table.draw_row(1, formatted_cells)
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

  describe "current row functionality" do
    it "initializes current_row_index to 0" do
      assert_equal 0, table.current_row_index
    end

    it "moves current_row_index up with navigate_up" do
      table.add_row({timestamp: "2025-01-01 12:00", message: "Row 1"})
      table.add_row({timestamp: "2025-01-01 12:01", message: "Row 2"})

      table.current_row_index = 1
      table.navigate_up

      assert_equal 0, table.current_row_index
    end

    it "moves current_row_index down with navigate_down" do
      table.add_row({timestamp: "2025-01-01 12:00", message: "Row 1"})
      table.add_row({timestamp: "2025-01-01 12:01", message: "Row 2"})

      table.navigate_down

      assert_equal 1, table.current_row_index
    end

    it "does not move above the first row" do
      table.add_row({timestamp: "2025-01-01 12:00", message: "Row 1"})

      table.current_row_index = 0
      table.navigate_up

      assert_equal 0, table.current_row_index
    end

    it "does not move below the last row" do
      table.add_row({timestamp: "2025-01-01 12:00", message: "Row 1"})
      table.add_row({timestamp: "2025-01-01 12:01", message: "Row 2"})

      table.current_row_index = 1
      table.navigate_down

      assert_equal 1, table.current_row_index
    end

    it "highlights the current row during rendering" do
      table.add_row({timestamp: "2025-01-01 12:00", message: "Row 1"})
      table.add_row({timestamp: "2025-01-01 12:01", message: "Row 2"})

      sequence = sequence("drawing")
      @mock_window.expects(:attron).with(Curses::A_REVERSE).in_sequence(sequence).yields
      @mock_window.expects(:setpos).with(1, 0).in_sequence(sequence)

      table.current_row_index = 0
      table.draw_body
    end

    it "scrolls when current_row_index moves off-screen" do
      Curses.stubs(:lines).returns(10) # Mock 10 lines for terminal height
      15.times { |i| table.add_row({timestamp: "2025-01-01 12:#{i.to_s.rjust(2, "0")}", message: "Row #{i}"}) }

      table.current_row_index = 12
      table.adjust_offset

      assert_equal 3, table.offset
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

    it 'navigates up with "KEY_UP"' do
      Curses.stubs(:getch).returns(Curses::KEY_UP)
      table.expects(:navigate_up).once
      table.handle_input
    end

    it 'navigates down with "KEY_DOWN"' do
      Curses.stubs(:getch).returns(Curses::KEY_DOWN)
      table.expects(:navigate_down).once
      table.handle_input
    end
  end
end

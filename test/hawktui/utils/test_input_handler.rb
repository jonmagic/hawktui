# frozen_string_literal: true

require "test_helper"
require "hawktui/utils/input_handler"

describe Hawktui::Utils::InputHandler do
  describe "#initialize" do
    it "sets up keybindings and UI" do
      keybindings = {"q" => ->(ui) { ui.quit }}
      ui = mock
      input_handler = Hawktui::Utils::InputHandler.new(keybindings: keybindings, ui: ui)

      assert_equal keybindings, input_handler.keybindings
      assert_equal ui, input_handler.ui
    end
  end

  describe "#handle_input" do
    it "calls the action for the given key" do
      keybindings = {"q" => ->(ui) { ui.quit }}
      ui = mock
      ui.expects(:quit).once
      input_handler = Hawktui::Utils::InputHandler.new(keybindings: keybindings, ui: ui)

      input_handler.handle_input("q")
    end

    it "does nothing for unknown keys" do
      keybindings = {"q" => ->(ui) { ui.quit }}
      ui = mock
      ui.expects(:quit).never
      input_handler = Hawktui::Utils::InputHandler.new(keybindings: keybindings, ui: ui)

      input_handler.handle_input("a")
    end
  end
end

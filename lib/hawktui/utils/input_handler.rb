module Hawktui
  module Utils
    class InputHandler
      # Public: Initialize a new InputHandler.
      #
      # keybindings - A Hash mapping keys to actions (Procs).
      # ui          - The UI object that actions will interact with.
      #
      # Examples
      #
      #   keybindings = {
      #     "p" => ->(ui) { ui.toggle_pause },
      #     " " => ->(ui) { ui.toggle_selection },
      #     Curses::KEY_DOWN => ->(ui) { ui.navigate_down }
      #   }
      #   ui = UI.new
      #   input_handler = Hawktui::Utils::InputHandler.new(keybindings: keybindings, ui: ui)
      #
      def initialize(keybindings:, ui:)
        @keybindings = keybindings
        @ui = ui
      end

      attr_reader :keybindings, :ui

      # Public: Handle input by executing the corresponding action.
      #
      # key - The key input as a String.
      #
      # Examples
      #
      #   input_handler.handle_input("a")
      #   # Executes the action associated with "a"
      #
      #   input_handler.handle_input("b")
      #   # Executes the action associated with "b"
      #
      def handle_input(key)
        action = keybindings[key]

        action&.call(ui)
      end
    end
  end
end

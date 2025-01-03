# frozen_string_literal: true

module Hawktui
  module Utils
    module Colors
      # Define base color ranges
      STANDARD_COLORS = (0..15).to_a
      COLOR_CUBE = (16..231).to_a
      GRAYSCALE = (232..255).to_a
      BASE_COLORS = {
        black: [0, 8],   # Standard and bright black
        red: [1, 9],   # Standard and bright red
        green: [2, 10],  # Standard and bright green
        yellow: [3, 11],  # Standard and bright yellow
        blue: [4, 12],  # Standard and bright blue
        magenta: [5, 13],  # Standard and bright magenta
        cyan: [6, 14],  # Standard and bright cyan
        white: [7, 15]  # Standard and bright white
      }.freeze

      # Human-readable mapping for colors
      COLOR_MAP = BASE_COLORS.keys.map(&:to_s).sort

      # Helper for composite colors (yellow, cyan, magenta)
      COMPOSITE_COLORS = {
        yellow: ->(r, g, b) { r == g && r > b },
        cyan: ->(r, g, b) { g == b && g > r },
        magenta: ->(r, g, b) { r == b && r > g }
      }.freeze

      # Public: Find all shades for a base or composite color in the color cube.
      # Returns an array of color indexes that represent different intensities
      # of the requested color within the 216-color cube (indexes 16-231).
      #
      # Examples
      #
      #   Colors.color_cube_shades(:red)
      #   # => [196, 197, 198, 199, 200, 201]
      #
      #   Colors.color_cube_shades(:yellow)
      #   # => [226, 227, 228, 229, 230]
      #
      # base_color - A Symbol or String representing the color to find shades for.
      #             Must be one of: red, green, blue, yellow, cyan, or magenta.
      #
      # Returns an Array of Integers representing color indexes in the color cube.
      def self.color_cube_shades(base_color)
        base_color = base_color.to_sym
        color_index = {red: 0, green: 1, blue: 2}[base_color]

        if color_index
          # Handle primary colors (red, green, blue)
          COLOR_CUBE.select do |color|
            r, g, b = color_cube_rgb(color)
            [r, g, b].each_with_index.max[1] == color_index
          end
        elsif COMPOSITE_COLORS[base_color]
          # Handle composite colors (yellow, cyan, magenta)
          COLOR_CUBE.select do |color|
            r, g, b = color_cube_rgb(color)
            COMPOSITE_COLORS[base_color].call(r, g, b)
          end
        else
          [] # Return empty array for unrecognized colors
        end
      end

      # Public: Decompose a color cube index into its RGB components.
      # Converts a color index (16-231) into RGB values on a scale of 0-5.
      #
      # Examples
      #
      #   Colors.color_cube_rgb(16)
      #   # => [0, 0, 0]
      #
      #   Colors.color_cube_rgb(231)
      #   # => [5, 5, 5]
      #
      # color - Integer representing the color index in the color cube (16-231)
      #
      # Returns an Array of three Integers representing RGB values (0-5)
      def self.color_cube_rgb(color)
        red_intensity = (color - 16) / 36
        green_intensity = ((color - 16) % 36) / 6
        blue_intensity = (color - 16) % 6
        [red_intensity, green_intensity, blue_intensity]
      end

      # Public: Get all available shades for a given color.
      # Combines both the base color values (standard + bright)
      # and any matching shades from the color cube.
      #
      # Examples
      #
      #   Colors.shades_for(:red)
      #   # => [1, 9, 196, 197, 198, 199, 200, 201]
      #
      #   Colors.shades_for(:white)
      #   # => [7, 15]
      #
      # color_name - A Symbol or String representing the color
      #
      # Returns an Array of Integers representing color indexes
      def self.shades_for(color_name)
        (BASE_COLORS[color_name.to_sym] || []) + color_cube_shades(color_name)
      end

      # Public: Initialize all possible color pairs for use with Curses.
      # Sets up 256 color pairs, each with a unique foreground color
      # and black background.
      #
      # Examples
      #
      #   Colors.setup_colors
      #   # => Sets up color pairs 1-256
      #
      # Returns nothing.
      def self.setup_colors
        Curses.start_color
        (0..255).each do |color|
          Curses.init_pair(color + 1, color, Curses::COLOR_BLACK)
        end
      end

      # Public: Get a comma-separated list of all available base colors.
      #
      # Examples
      #
      #   Colors.available_colors
      #   # => "black, blue, cyan, green, magenta, red, white, yellow"
      #
      # Returns a String of color names separated by commas
      def self.available_colors
        COLOR_MAP.join(", ")
      end
    end
  end
end

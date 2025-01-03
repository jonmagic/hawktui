# frozen_string_literal: true

require "test_helper"
require "hawktui/utils/colors"

describe Hawktui::Utils::Colors do
  describe ".color_cube_shades" do
    it "returns the correct shades for primary colors" do
      assert_equal [52, 88, 89, 94, 95, 124, 125, 126, 130, 131, 132, 136, 137, 138, 160, 161, 162, 163, 166, 167, 168, 169, 172, 173, 174, 175, 178, 179, 180, 181, 196, 197, 198, 199, 200, 202, 203, 204, 205, 206, 208, 209, 210, 211, 212, 214, 215, 216, 217, 218, 220, 221, 222, 223, 224], Hawktui::Utils::Colors.color_cube_shades(:red)
      assert_equal [22, 28, 29, 34, 35, 36, 40, 41, 42, 43, 46, 47, 48, 49, 50, 58, 64, 65, 70, 71, 72, 76, 77, 78, 79, 82, 83, 84, 85, 86, 100, 101, 106, 107, 108, 112, 113, 114, 115, 118, 119, 120, 121, 122, 142, 143, 144, 148, 149, 150, 151, 154, 155, 156, 157, 158, 184, 185, 186, 187, 190, 191, 192, 193, 194, 226, 227, 228, 229, 230], Hawktui::Utils::Colors.color_cube_shades(:green)
      assert_equal [16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 30, 31, 32, 33, 37, 38, 39, 44, 45, 51, 53, 54, 55, 56, 57, 59, 60, 61, 62, 63, 66, 67, 68, 69, 73, 74, 75, 80, 81, 87, 90, 91, 92, 93, 96, 97, 98, 99, 102, 103, 104, 105, 109, 110, 111, 116, 117, 123, 127, 128, 129, 133, 134, 135, 139, 140, 141, 145, 146, 147, 152, 153, 159, 164, 165, 170, 171, 176, 177, 182, 183, 188, 189, 195, 201, 207, 213, 219, 225, 231], Hawktui::Utils::Colors.color_cube_shades(:blue)
    end

    it "returns the correct shades for composite colors" do
      assert_equal [58, 100, 101, 142, 143, 144, 184, 185, 186, 187, 226, 227, 228, 229, 230], Hawktui::Utils::Colors.color_cube_shades(:yellow)
      assert_equal [23, 30, 37, 44, 51, 66, 73, 80, 87, 109, 116, 123, 152, 159, 195], Hawktui::Utils::Colors.color_cube_shades(:cyan)
      assert_equal [53, 90, 96, 127, 133, 139, 164, 170, 176, 182, 201, 207, 213, 219, 225], Hawktui::Utils::Colors.color_cube_shades(:magenta)
    end

    it "returns an empty array for unknown colors" do
      assert_equal [], Hawktui::Utils::Colors.color_cube_shades(:unknown)
    end
  end

  describe ".color_cube_rgb" do
    it "decomposes a color cube index into RGB components" do
      assert_equal [0, 0, 0], Hawktui::Utils::Colors.color_cube_rgb(16)
      assert_equal [5, 5, 5], Hawktui::Utils::Colors.color_cube_rgb(231)
      assert_equal [1, 2, 3], Hawktui::Utils::Colors.color_cube_rgb(16 + 1 * 36 + 2 * 6 + 3)
    end
  end

  describe ".shades_for" do
    it "returns all available shades for a base color" do
      assert_equal [1, 9, 52, 88, 89, 94, 95, 124, 125, 126, 130, 131, 132, 136, 137, 138, 160, 161, 162, 163, 166, 167, 168, 169, 172, 173, 174, 175, 178, 179, 180, 181, 196, 197, 198, 199, 200, 202, 203, 204, 205, 206, 208, 209, 210, 211, 212, 214, 215, 216, 217, 218, 220, 221, 222, 223, 224], Hawktui::Utils::Colors.shades_for(:red)
      assert_equal [7, 15], Hawktui::Utils::Colors.shades_for(:white)
    end

    it "returns an empty array for an unknown color" do
      assert_equal [], Hawktui::Utils::Colors.shades_for(:unknown)
    end
  end

  describe ".setup_colors" do
    it "sets up 256 color pairs for Curses" do
      Curses.expects(:start_color).once
      (0..255).each { |color| Curses.expects(:init_pair).with(color + 1, color, Curses::COLOR_BLACK).once }
      Hawktui::Utils::Colors.setup_colors
    end
  end

  describe ".available_colors" do
    it "returns a comma-separated list of all available base colors" do
      expected_colors = "black, blue, cyan, green, magenta, red, white, yellow"
      assert_equal expected_colors, Hawktui::Utils::Colors.available_colors
    end
  end
end

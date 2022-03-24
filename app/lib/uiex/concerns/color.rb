# https://html-color.codes/blue

class Color
  attr_accessor :r, :g, :b, :a

  def initialize(r, g, b, a = 255)
    @r = r
    @g = g
    @b = b
    @a = a
  end

  def to_h
    { r: @r, g: @g, b: @b, a: @a }
  end

  WHITE = Color.new(255, 255, 255)
  LIGHT_GREY = Color.new(240, 240, 240)
  GREY = Color.new(128, 128, 128)
  DARK_GREY = Color.new(32, 32, 32)
  BLACK = Color.new(0, 0, 0)
  RED = Color.new(128, 0, 0)
  STEEL_BLUE = Color.new(70, 130, 180)
  TRANSPARENT = Color.new(0, 0, 0, 0)
end

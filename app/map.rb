LEVEL1 = <<-MAP.lines.reverse
X..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..X
................................................................
................................................................
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............XXXXXXXX..................XXXXXXXX..............X
X..............X................................X..............X
X..............X................................X..............X
X..............................................................X
X..............................................................X
................................................................
................................................................
X..............................................................X
X..............................................................X
X..............................................................X
X..............X................................X..............X
X..............X................................X..............X
X..............XXXXXXXX..................XXXXXXXX..............X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
X..............................................................X
................................................................
................................................................
X..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..X
MAP

class Map
  include Easing

  TARGET = :map
  APPEAR_DURATION = 25

  def initialize
    rt = $args.render_target(TARGET)
    rt.primitives << walls

    @primitive = { x: 0, y: 0, w: 1280, h: 720, path: TARGET, source_x: 0, source_y: 0, source_w: 1280, source_h: 720 }.sprite!
    @state = :hidden
  end

  def appear!
    @state = :appearing
    @start = $args.tick_count
  end

  def to_p
    case @state
    when :visible
      @primitive
    when :appearing
      ticks = $args.tick_count - @start
      @state = :visible if ticks >= APPEAR_DURATION
      @primitive[:a] = ease_in_quart(ticks, APPEAR_DURATION) * 255
      @primitive
    # when :rising
    #   ticks = $args.tick_count - @start
    #   @state = :hidden if ticks >= RISE_DURATION
    #   @primitive[:y] = ease_in_back(ticks, RISE_DURATION) * 720
    #   @primitive
    else
      nil
    end
  end

  def wall?(x, y)
    LEVEL1[y][x] == 'X'
  end

  private

  def walls
    [].tap do |walls|
      GRID_HEIGHT.times do |y|
        GRID_WIDTH.times do |x|
          walls << block([x, y]) if LEVEL1[y][x] == 'X'
        end
      end
    end
  end

  def block(pos, color = { r: 47, g: 79, b: 79 })
    { x: pos.x * GRID_SIZE, y: pos.y * GRID_SIZE, w: GRID_SIZE, h: GRID_SIZE }.solid!(color)
  end
end
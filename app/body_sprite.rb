class BodySprite
  BODY_DEFAULTS = { w: GRID_SIZE, h: GRID_SIZE, path: 'sprites/body3.png' }
  TAIL_DEFAULTS = {
    w: GRID_SIZE,
    h: GRID_SIZE, path: 'sprites/tail1.png',
    source_y: 0,
    source_w: 10,
    source_h: 10
  }
  TAIL_FRAMES = [0, 1, 2, 1, 3, 4]
  TOTAL_FRAMES = TAIL_FRAMES.length
  TICKS_PER_FRAME = 10

  attr_accessor :logical_x, :logical_y, :direction, :tail

  def initialize(pos, dir, tail = false)
    @logical_x = pos.x
    @logical_y = pos.y
    @direction = dir
    @tail = tail
  end

  def tail?
    tail
  end

  def move_to(pos)
    @logical_x = pos.x
    @logical_y = pos.y
  end

  def update(pos, dir, tail)
    move_to(pos)
    @direction = dir
    @tail = tail
    self
  end

  def logical_position
    [logical_x, logical_y]
  end

  def to_p
    angle = case direction
            when :right then 0
            when :up then 90
            when :left then 180
            when :down then 270
            end

    tail? ? tail_p(angle) : body_p(angle)
  end

  def body_p(angle)
    { x: logical_x * GRID_SIZE, y: logical_y * GRID_SIZE, angle: angle }.sprite!(BODY_DEFAULTS)
  end

  def tail_p(angle)
    frame = $args.tick_count.idiv(TICKS_PER_FRAME) % TOTAL_FRAMES

    {
      x: logical_x * GRID_SIZE,
      y: logical_y * GRID_SIZE,
      source_x: TAIL_FRAMES[frame] * 10,
      angle: angle
    }.sprite!(TAIL_DEFAULTS)
  end
end

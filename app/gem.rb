class Gem
  ANIM_FRAMES = 5
  TOTAL_FRAMES = (ANIM_FRAMES - 2) * 2 + 2
  FORWARD_FRAMES = TOTAL_FRAMES / 2
  TICKS_PER_FRAME = 12

  def initialize(x, y)
    move_to x, y
  end

  def move_to(x, y)
    @x = x
    @y = y
  end

  def to_p
    frame = (c = $args.tick_count.idiv(TICKS_PER_FRAME) % TOTAL_FRAMES) > FORWARD_FRAMES ? TOTAL_FRAMES - c : c

    {
      x: @x * GRID_SIZE,
      y: @y * GRID_SIZE,
      w: GRID_SIZE,
      h: GRID_SIZE,
      path: 'sprites/gem4.png',
      source_x: frame * 10,
      source_y: 0,
      source_w: 10,
      source_h: 10
    }.sprite!
  end
end
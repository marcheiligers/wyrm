class Coin
  ANIM_FRAMES = 5
  TOTAL_FRAMES = (ANIM_FRAMES - 2) * 2 + 2
  FORWARD_FRAMES = TOTAL_FRAMES / 2
  TICKS_PER_FRAME = 12

  def initialize(x = 0, y = 0, dark = false)
    move_to x, y
    @visible = true
    @dark = dark
  end

  def move_to(x, y)
    @x = x
    @y = y
  end

  def location
    [@x, @y]
  end

  def show!
    @visible = true
  end

  def hide!
    @visible = false
  end

  def visible?
    @visible
  end

  def dark!
    @dark = true
  end

  def light!
    @dark = false
  end

  def to_p
    return unless visible?

    frame = (c = $args.tick_count.idiv(TICKS_PER_FRAME) % TOTAL_FRAMES) > FORWARD_FRAMES ? TOTAL_FRAMES - c : c

    {
      x: @x * GRID_SIZE,
      y: @y * GRID_SIZE,
      w: GRID_SIZE,
      h: GRID_SIZE,
      path: @dark ? 'sprites/gem-dark.png' : 'sprites/gem4.png',
      source_x: @dark ? 0 : frame * 10,
      source_y: 0,
      source_w: 10,
      source_h: 10
    }.sprite!
  end
end
class Portal
  ANIM_FRAMES = 3
  TICKS_PER_FRAME = 10

  def initialize
    @x = PORTAL_LOCATION.x
    @y = PORTAL_LOCATION.y
    @frame = 0 
    @start_tick = $args.tick_count
    @visible = false
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

  def location
    [@x + 1, @y + 1]
  end

  def to_p
    return unless visible?

    @frame = (@frame + 1) % ANIM_FRAMES if ($args.tick_count - @start_tick) % TICKS_PER_FRAME == 0

    {
      x: @x * GRID_SIZE,
      y: @y * GRID_SIZE,
      w: 30 * PIXEL_MUL,
      h: 30 * PIXEL_MUL,
      path: 'sprites/portal3.png',
      source_x: @frame * 30,
      source_y: 0,
      source_w: 30,
      source_h: 30
    }.sprite!
  end
end

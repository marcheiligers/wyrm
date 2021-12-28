class Portal
  ANIM_FRAMES = 3
  TICKS_PER_FRAME = 10

  def initialize(x, y)
    @x = x
    @y = y
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

  def to_p
    return unless visible?

    @frame = (@frame + 1) % ANIM_FRAMES if ($args.tick_count - @start_tick) % TICKS_PER_FRAME == 0

    {
      x: @x,
      y: @y,
      w: 30 * PIXEL_MUL,
      h: 30 * PIXEL_MUL,
      path: 'sprites/portal2.png',
      source_x: @frame * 30,
      source_y: 0,
      source_w: 30,
      source_h: 30
    }.sprite!
  end
end

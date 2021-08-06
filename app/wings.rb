class Wings
  ANIM_FRAMES = 3
  TOTAL_FRAMES = (ANIM_FRAMES - 2) * 2 + 2
  FORWARD_FRAMES = TOTAL_FRAMES / 2
  TICKS_PER_FRAME = 8

  def initialize(wyrm)
    @wyrm = wyrm
  end

  def to_p
    frame = (c = $args.tick_count.idiv(TICKS_PER_FRAME) % TOTAL_FRAMES) > FORWARD_FRAMES ? TOTAL_FRAMES - c : c
    case @wyrm.direction
    when :left
      angle = 180
      x = @wyrm.logical_x + 1
      y = @wyrm.logical_y - 1
    when :right
      angle = 0
      x = @wyrm.logical_x - 1
      y = @wyrm.logical_y - 1
    when :up
      angle = 90
      x = @wyrm.logical_x
      y = @wyrm.logical_y - 2
    when :down
      angle = -90
      x = @wyrm.logical_x
      y = @wyrm.logical_y
    end

    {
      x: x * GRID_SIZE,
      y: y * GRID_SIZE,
      w: GRID_SIZE,
      h: GRID_SIZE * 3,
      path: 'sprites/wings2.png',
      angle: angle,
      source_x: frame * 10,
      source_y: 0,
      source_w: 10,
      source_h: 30
    }.sprite!
  end
end
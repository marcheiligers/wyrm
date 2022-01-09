class WingsSprite
  ANIM_FRAMES = 3
  TOTAL_FRAMES = (ANIM_FRAMES - 2) * 2 + 2
  FORWARD_FRAMES = TOTAL_FRAMES / 2
  TICKS_PER_FRAME = 8

  attr_reader :logical_x, :logical_y, :direction

  def initialize(pos = nil, dir = nil)
    @logical_x = pos&.x || Game::PORTAL_LOCATION.x + 1
    @logical_y = pos&.y || Game::PORTAL_LOCATION.y + 1
    @direction = dir || :right
  end

  def move_to(pos)
    @logical_x = pos.x
    @logical_y = pos.y
  end

  def update(pos, dir)
    move_to(pos)
    @direction = dir
    self
  end

  def to_p
    frame = (c = $args.tick_count.idiv(TICKS_PER_FRAME) % TOTAL_FRAMES) > FORWARD_FRAMES ? TOTAL_FRAMES - c : c
    case @direction
    when :left
      angle = 180
      x = @logical_x + 1
      y = @logical_y - 1
    when :right
      angle = 0
      x = @logical_x - 1
      y = @logical_y - 1
    when :up
      angle = 90
      x = @logical_x
      y = @logical_y - 2
    when :down
      angle = -90
      x = @logical_x
      y = @logical_y
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
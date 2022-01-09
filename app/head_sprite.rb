class HeadSprite
  attr_reader :logical_x, :logical_y, :direction
	attr_sprite

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

  # The head sprite is 14x14 to accommodate the horns, so it's offset a little
  def to_p
    case @direction
    when :left
      angle = -90
      x = @logical_x * GRID_SIZE
      y = @logical_y * GRID_SIZE - 4
    when :right
      angle = 90
      x = @logical_x * GRID_SIZE - 8
      y = @logical_y * GRID_SIZE - 4
    when :up
      angle = 180
      x = @logical_x * GRID_SIZE - 4
      y = @logical_y * GRID_SIZE - 8
    when :down
      angle = 0
      x = @logical_x * GRID_SIZE - 4
      y = @logical_y * GRID_SIZE
    end

    { x: x, y: y, w: GRID_SIZE + 8, h: GRID_SIZE + 8, path: 'sprites/head3.png', angle: angle }.sprite!
  end
end

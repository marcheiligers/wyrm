class Wyrm
  attr_reader :logical_x, :logical_y, :length, :direction

  def initialize
    @body = Body.new(self)
  end

  def reset
    @direction = :right
    @logical_x = GRID_WIDTH / 2
    @logical_y = GRID_HEIGHT / 2
    @ticks = 0
    @move_ticks = MAX_MOVE_TICKS

    @body.reset
  end

  def head
    [@logical_x, @logical_y]
  end

  def include?(pos)
    head == pos || @body.include?(pos)
  end

  def crashed_into_self?
    @body.include?(head)
  end

  def handle_input
    inputs = $args.inputs

    case
    when inputs.keyboard.key_down.right then @direction = :right
    when inputs.keyboard.key_down.left then @direction = :left
    when inputs.keyboard.key_down.up then @direction = :up
    when inputs.keyboard.key_down.down then @direction = :down
    end
  end

  def handle_move
    @ticks += 1
    holding = $args.inputs.keyboard.key_held.send(@direction)
    move_ticks = holding ? MIN_MOVE_TICKS : @move_ticks
    return unless @ticks > move_ticks

    @ticks = 0
    @body.move

    case @direction
    when :right then @logical_x += 1
    when :left then @logical_x -= 1
    when :up then @logical_y += 1
    when :down then @logical_y -= 1
    end

    @logical_x = 0 if @logical_x >= GRID_WIDTH
    @logical_x = GRID_WIDTH - 1 if @logical_x < 0
    @logical_y = 0 if @logical_y >= GRID_HEIGHT
    @logical_y = GRID_HEIGHT - 1 if @logical_y < 0
  end

  def grow
    @body.grow
    @move_ticks = move_ticks
  end

  def move_ticks
    [((1 - $args.easing.ease(0, @length, MOVE_MAX_LENGTH, :quad)) * MAX_MOVE_TICKS).round, MIN_MOVE_TICKS].max
  end

  def to_p
    [head_sprite, wings_sprite] + @body.to_p
  end

  def head_sprite
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

  def wings_sprite
    anim = ($args.tick_count / 10).to_i % 3
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
      path: 'sprites/wings.png',
      angle: angle,
      source_x: anim * 5,
      source_y: 0,
      source_w: 5,
      source_h: 15
    }.sprite!
  end
end
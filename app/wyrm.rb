class Wyrm
  MAX_MOVE_TICKS = 30
  MIN_MOVE_TICKS = 4
  MOVE_MAX_LENGTH = 100

  ACCEL_MOD = 5
  DECCEL_MOD = 8

  attr_reader :logical_x, :logical_y, :length, :direction

  def initialize
    @body = Body.new(self)
    @wings = Wings.new(self)
  end

  def reset
    @direction = :right
    @next_direction = :right
    @logical_x = GRID_WIDTH / 2
    @logical_y = GRID_HEIGHT / 2
    @ticks = 0
    @move_ticks = MAX_MOVE_TICKS # number of ticks between moves
    @accel_move_ticks = 0 # number of ticks to subtact from @move_ticks due to acceleration

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
    if inputs.keyboard.key_held.truthy_keys.length > 2 # always has [:raw_key, :char]
      if $args.tick_count % @move_ticks.idiv(ACCEL_MOD) == 0
        @accel_move_ticks = [@accel_move_ticks + 1, @move_ticks.idiv(2)].min
      end
    else
      if $args.tick_count % @move_ticks.idiv(DECCEL_MOD) == 0
        @accel_move_ticks = [@accel_move_ticks - 1, 0].max
      end
    end

    case
    when inputs.keyboard.key_down.right then @next_direction = :right
    when inputs.keyboard.key_down.left then @next_direction = :left
    when inputs.keyboard.key_down.up then @next_direction = :up
    when inputs.keyboard.key_down.down then @next_direction = :down
    end
  end

  def handle_move
    @ticks += 1
    return unless should_move?

    @direction = @next_direction
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
    @logical_y = 0 if @logical_y >= GRID_HEIGHT - 1 # top row is reserved for title and score
    @logical_y = (GRID_HEIGHT - 1) - 1 if @logical_y < 0 
  end

  def should_move?
    move_ticks = [MIN_MOVE_TICKS, @move_ticks - @accel_move_ticks].max
    @ticks > move_ticks
  end

  def grow
    @body.grow
    @move_ticks = move_ticks
  end

  def move_ticks
    [((1 - $args.easing.ease(0, @body.length, MOVE_MAX_LENGTH, :quad)) * MAX_MOVE_TICKS).round, MIN_MOVE_TICKS].max
  end

  def to_p
    [head_sprite, @wings.to_p, @body.to_p]
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
end
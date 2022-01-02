class Wyrm
  MAX_MOVE_TICKS = 30
  MIN_MOVE_TICKS = 4
  MOVE_MAX_LENGTH = 100

  PORTAL_MOVE_TICKS = 10

  ACCEL_MOD = 5
  DECCEL_MOD = 8

  attr_reader :logical_x, :logical_y, :direction, :state

  # State 
  # => :normal - normal game state
  # => :portal_enter - disappearing into the portal
  # => :portal_entered - disappeared into the portal
  # => :portal_exit - disappearing into the portal

  def initialize
    @body = Body.new(self)
    @wings = Wings.new(self)
  end

  def reset
    @move_ticks = MAX_MOVE_TICKS # number of ticks between moves
    @accel_move_ticks = 0 # number of ticks to subtact from @move_ticks due to acceleration

    @body.reset
    exit_portal!
  end

  def head
    [@logical_x, @logical_y]
  end

  def enter_portal!
    @state = :portal_enter
    @portal_length = 1
  end

  def exit_portal!
    @direction = :right
    @next_direction = :right
    @ticks = 0
    @logical_x = 15
    @logical_y = 8
    @state = :portal_exit
    @portal_length = @body.length + 1
    @body.exit_portal!
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

    @direction = @next_direction unless @state == :portal_enter

    if @state == :portal_enter
puts "#{@portal_length} #{@body.length}"
      @portal_length += 1 
      @state = :portal_entered if @portal_length == @body.length + 2
    end

    if @state == :portal_exit
      @portal_length -= 1
      @state = :normal if @portal_length == 0
    end

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
    move_ticks = if @state == :portal_enter
                   MIN_MOVE_TICKS
                 else
                   [MIN_MOVE_TICKS, @move_ticks - @accel_move_ticks].max
                 end
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
    case state
    when :normal
      [head_sprite, @wings.to_p, @body.to_p]
    when :portal_enter
      case @portal_length
      when 0 then [head_sprite, @wings.to_p, @body.to_p]
      when 1 then [@wings.to_p, @body.to_p]
      else @body.to_p([@portal_length - 2, 0].max)
      end
    when :portal_exit
      case @portal_length
      when @body.length + 1 then [head_sprite]
      when @body.length then [head_sprite, @wings.to_p, @body.to_p(@body.length - 1)]
      else [head_sprite, @wings.to_p, @body.to_p(@portal_length - 1)]
      end
    end
  end

  # The head sprite is 14x14 to accommodate the horns, so it's offset a little
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
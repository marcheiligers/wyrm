class Wyrm
  include InputManager

  MOVE_MAX_LENGTH = 100

  ACCEL_MOD = 5
  DECCEL_MOD = 8

  attr_reader :logical_x, :logical_y, :direction, :state, :move_ticks

  # State
  # => :normal - normal game state
  # => :portal_enter - disappearing into the portal
  # => :portal_entered - disappeared into the portal
  # => :portal_exit - disappearing into the portal

  def initialize
    @head = HeadSprite.new
    @wings = WingsSprite.new
    @body = Body.new(self)
    @move_ticks = $game.max_move_ticks # number of ticks between moves
  end

  def reset
    @move_ticks = $game.max_move_ticks # number of ticks between moves
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
    @direction_queue = []
    @ticks = 0
    @logical_x = 15
    @logical_y = 8
    @state = :portal_exit
    @portal_length = @body.length + 1
    @head.update(head, direction)
    @wings.update(head, direction)
    @body.exit_portal!
  end

  def include?(pos)
    head == pos || @body.include?(pos)
  end

  def crashed_into_self?
    @body.include?(head)
  end

  def handle_input
    if any_key_held? # always has [:raw_key, :char]
      if $args.tick_count % [@move_ticks.idiv(ACCEL_MOD), 1].max == 0
        @accel_move_ticks = [@accel_move_ticks + 1, @move_ticks.idiv(1.5)].min
      end
    elsif $args.tick_count % [@move_ticks.idiv(DECCEL_MOD), 1].max == 0
      @accel_move_ticks = [@accel_move_ticks - 1, 0].max
    end

    dir = direction_down
    if $game.queue_dir_changes
      case dir
      when :right then @direction_queue << :right if should_turn?(:right)
      when :left then @direction_queue << :left if should_turn?(:left)
      when :up then @direction_queue << :up if should_turn?(:up)
      when :down then @direction_queue << :down if should_turn?(:down)
      end
    else
      case dir
      when :right then @next_direction = :right if @direction != :left
      when :left then @next_direction = :left if @direction != :right
      when :up then @next_direction = :up if @direction != :down
      when :down then @next_direction = :down if @direction != :up
      end
    end
  end

  OPPOSITE = {
    right: :left,
    left: :right,
    up: :down,
    down: :up
  }.freeze

  def should_turn?(dir)
    if @direction_queue.empty?
      @direction != OPPOSITE[dir]
    else
      @direction_queue.last != dir && @direction_queue.last != OPPOSITE[dir]
    end
  end

  def handle_move
    @ticks += 1
    return unless should_move?

    $args.outputs.sounds << 'sounds/move1.wav' if $game.sound_fx

    if $game.queue_dir_changes
      @direction = @direction_queue.shift || @direction
    else
      @direction = @next_direction unless @state == :portal_enter
    end

    if @state == :portal_enter
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

    @head.update(head, direction)
    @wings.update(head, direction)
  end

  def should_move?
    move_ticks = if @state == :portal_enter
                   $game.min_move_ticks
                 else
                   current_move_ticks
                 end
    @ticks > move_ticks
  end

  def grow
    @body.grow
    @move_ticks = calc_move_ticks
  end

  def current_move_ticks
    [$game.min_move_ticks, @move_ticks - @accel_move_ticks].max
  end

  def calc_move_ticks
    [((1 - $args.easing.ease(0, @body.length, MOVE_MAX_LENGTH, :quad)) * $game.max_move_ticks).round, $game.min_move_ticks].max
  end

  def to_p
    case state
    when :normal
      [@body.to_p, @wings.to_p, @head.to_p]
    when :portal_enter
      case @portal_length
      when 0 then [@body.to_p, @wings.to_p, @head.to_p]
      when 1 then [@body.to_p, @wings.to_p]
      else @body.to_p([@portal_length - 2, 0].max)
      end
    when :portal_exit
      case @portal_length
      when @body.length + 1 then [@head.to_p]
      when @body.length then [@wings.to_p, @body.to_p(@body.length - 1), @head.to_p]
      else [@wings.to_p, @body.to_p(@portal_length - 1), @head.to_p]
      end
    end
  end
end

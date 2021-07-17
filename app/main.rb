GRID_SIZE = 20
GRID_WIDTH = $gtk.args.grid.w / GRID_SIZE
GRID_HEIGHT = $gtk.args.grid.h / GRID_SIZE
GRID_CENTER = $gtk.args.grid.w / 2
GRID_MIDDLE = $gtk.args.grid.h / 2
MAX_TICKS = 15
MIN_TICKS = 3
MOVE_MAX_LENGTH = 30

class Snake
  def initialize
    reset
    @state = :new_game
  end

  def tick(args)
    case @state
    when :new_game, :game_over
      handle_menu(args)
    when :game
      handle_input(args)
      handle_move(args)
      handle_edges
      handle_collisions
      handle_fruit(args)
    end

    args.outputs.primitives << to_p
  end

  def handle_input(args)
    inputs = args.inputs

    case
    when inputs.right then @direction = :right
    when inputs.left then @direction = :left
    when inputs.up then @direction = :up
    when inputs.down then @direction = :down
    end
  end

  def handle_move(args)
    @ticks += 1
    move_ticks = args.inputs.keyboard.key_held.space ? MIN_TICKS : @move_ticks
    return unless @ticks > move_ticks

    @ticks = 0

    if @length > @body.length
      @body << head
    elsif @body.length > 0
      @body.shift
      @body << head
    end

    case @direction
    when :right then @logical_x += 1
    when :left then @logical_x -= 1
    when :up then @logical_y += 1
    when :down then @logical_y -= 1
    end
  end

  def handle_edges
    @logical_x = 0 if @logical_x > GRID_WIDTH
    @logical_x = GRID_WIDTH if @logical_x < 0
    @logical_y = 0 if @logical_y > GRID_HEIGHT
    @logical_y = GRID_HEIGHT if @logical_y < 0
  end

  def handle_collisions
    if @body.include?(head)
      # we crashed into ourselves
      @state = :game_over
    end
  end

  def handle_fruit(args)
    return unless head == @fruit

    @length += 1
    @move_ticks = move_ticks(args)
    @fruit = random_fruit
  end

  def handle_menu(args)
    reset if args.inputs.keyboard.key_up.space
  end

  def random_fruit
    [
      rand(GRID_WIDTH),
      rand(GRID_HEIGHT)
    ]
  end

  def reset
    @direction = :right
    @ticks = 0
    @move_ticks = MAX_TICKS
    @logical_x = GRID_WIDTH / 2
    @logical_y = GRID_HEIGHT / 2
    @length = 0
    @body = []
    @fruit = random_fruit
    @state = :game
  end

  def move_ticks(args)
    [((1 - args.easing.ease(0, @length, MOVE_MAX_LENGTH, :quad)) * MAX_TICKS).round, MIN_TICKS].max
  end

  def to_p
    case @state
    when :new_game
      [text('WYRM'), text('Press [SPACE] to play', -50)]
    when :game
      [section(head, { r: 0, g: 0, b: 0 })] +
        @body.map { |pos| section(pos) } +
        [section(@fruit, { r: 200, g: 12, b: 12 })]
    when :game_over
      [text('GAME OVER'), text('Press [SPACE] to play again', -50)]
    end
  end

  def section(pos, color = { r: 12, g: 100, b: 12 })
    { x: pos.x * GRID_SIZE, y: pos.y * GRID_SIZE, w: GRID_SIZE, h: GRID_SIZE }.merge(color).solid
  end

  def text(str, y_offset = 0)
    { x: GRID_CENTER, y: GRID_MIDDLE + y_offset, text: str, size_enum: 2, alignment_enum: 1, r: 155, g: 50, b: 50, a: 255, vertical_alignment_enum: 1 }
  end

  def head
    [@logical_x, @logical_y]
  end
end

$snake = Snake.new

def tick(args)
  $snake.tick(args)
end

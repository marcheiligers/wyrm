GRID_SIZE = 20
GRID_WIDTH = $gtk.args.grid.w / GRID_SIZE
GRID_HEIGHT = $gtk.args.grid.h / GRID_SIZE
GRID_CENTER = $gtk.args.grid.w / 2
GRID_MIDDLE = $gtk.args.grid.h / 2

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
      handle_collisions
      handle_fruit
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
    return unless args.tick_count % @speed == 0

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

  def handle_collisions
    if @body.include?(head)
      # we crashed into ourselves
      @state = :game_over
    elsif @logical_x < 0 || @logical_x > GRID_WIDTH || @logical_y < 0 || @logical_y > GRID_HEIGHT
      # we crashed into the edge
      @state = :game_over
    end
  end

  def handle_fruit
    return unless head == @fruit

    @length += 1
    @speed -= 1
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
    @speed = 20
    @logical_x = GRID_WIDTH / 2
    @logical_y = GRID_HEIGHT / 2
    @length = 0
    @body = []
    @fruit = random_fruit
    @state = :game
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

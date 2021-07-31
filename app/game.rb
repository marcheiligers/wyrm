GRID_SIZE = 20
GRID_WIDTH = $gtk.args.grid.w / GRID_SIZE
GRID_HEIGHT = $gtk.args.grid.h / GRID_SIZE
GRID_CENTER = $gtk.args.grid.w / 2
GRID_MIDDLE = $gtk.args.grid.h / 2
MAX_MOVE_TICKS = 15
MIN_MOVE_TICKS = 3
MOVE_MAX_LENGTH = 30
POINTS = [500, 250, 200, 150, 100, 75, 50, 25, 10, 5, 3, 2, 1]
MAX_POINT_TICKS = 600
PRIMARY_FONT = 'fonts/BLKCHCRY.TTF'
SECONDARY_FONT = 'fonts/MayflowerAntique.ttf'

class Snake
  def initialize
    reset
    @state = :new_game
    @menu = Menu.new
    @menu.drop!
    @map = Map.new
  end

  def tick(args)
    case @state
    when :new_game, :game_over
      handle_menu(args)
    when :game_starting
      @menu.rise!
      @map.appear!
      @state = :menu_rising
    when :menu_rising
      @state = :game if @menu.finished?
      @fruit_tick = args.tick_count
    when :game
      handle_input(args)
      handle_move(args)
      handle_edges
      handle_collisions
      handle_fruit(args)
    end

    args.outputs.background_color = [135, 206, 250]
    args.outputs.primitives << to_p
  end

  def handle_input(args)
    inputs = args.inputs

    case
    when inputs.keyboard.key_down.right then @direction = :right
    when inputs.keyboard.key_down.left then @direction = :left
    when inputs.keyboard.key_down.up then @direction = :up
    when inputs.keyboard.key_down.down then @direction = :down
    end
  end

  def handle_move(args)
    @ticks += 1
    holding = args.inputs.keyboard.key_held.send(@direction)
    move_ticks = holding ? MIN_MOVE_TICKS : @move_ticks
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
    @logical_x = 0 if @logical_x >= GRID_WIDTH
    @logical_x = GRID_WIDTH - 1 if @logical_x < 0
    @logical_y = 0 if @logical_y >= GRID_HEIGHT
    @logical_y = GRID_HEIGHT - 1 if @logical_y < 0
  end

  def handle_collisions
    if @body.include?(head)
      # we crashed into ourselves
      puts "Crashed into ourselves"
      @state = :game_over
    elsif @map.wall?(@logical_x, @logical_y)
      # we crashed into a wall
      puts "Crashed into a wall"
      @state = :game_over
    end
  end

  def handle_fruit(args)
    return unless head == @fruit

    @length += 1
    @move_ticks = move_ticks(args)
    points = [POINTS[(args.easing.ease(0, args.tick_count - @fruit_tick, MAX_POINT_TICKS, :identity) * POINTS.length).round].to_i, 1].max
    @score += points
    label = FruitScoreLabel.new(@logical_x * GRID_SIZE + GRID_SIZE / 2, @logical_y * GRID_SIZE, points.to_s, 5)
    label.animate
    @animations << label
    @fruit = random_fruit
    @fruit_tick = args.tick_count
  end

  def handle_menu(args)
    reset if args.inputs.keyboard.key_up.space
  end

  def random_fruit
    found = false
    begin
      pos = [rand(GRID_WIDTH), rand(GRID_HEIGHT)]
      found = true if LEVEL1[pos.y][pos.x] != 'X' && !@body.include?(pos)
    end while !found
    pos
  end

  def reset
    @direction = :right
    @ticks = 0
    @move_ticks = MAX_MOVE_TICKS
    @logical_x = GRID_WIDTH / 2
    @logical_y = GRID_HEIGHT / 2
    @length = 1
    @body = []
    @fruit = random_fruit
    @state = :game_starting
    @score = 0
    @animations = []
    $gtk.args.outputs.static_primitives.clear
  end

  def move_ticks(args)
    [((1 - args.easing.ease(0, @length, MOVE_MAX_LENGTH, :quad)) * MAX_MOVE_TICKS).round, MIN_MOVE_TICKS].max
  end

  def to_p
    case @state
    when :new_game, :game_starting
      @menu.to_p
    when :menu_rising
      [@map.to_p, head_sprite, fruit_sprite, score, @menu.to_p]
    when :game
      @animations.reject!(&:finished?)
      [@map.to_p] + @body.map { |pos| body_sprite(pos) } + [head_sprite, fruit_sprite, score] + @animations.map(&:to_p)
    when :game_over
      [text('GAME OVER'), text('Press [SPACE] to play again', -50), score]
    end
  end

  def head_sprite
    angle = case @direction
            when :left then -90
            when :right then 90
            when :up then 180
            when :down then 0
            end
    { x: @logical_x * GRID_SIZE, y: @logical_y * GRID_SIZE, w: GRID_SIZE, h: GRID_SIZE, path: 'sprites/snake.png', angle: angle }.sprite
  end

  def body_sprite(pos)
    { x: pos.x * GRID_SIZE, y: pos.y * GRID_SIZE, w: GRID_SIZE, h: GRID_SIZE, path: 'sprites/body.png' }.sprite
  end

  def fruit_sprite
    { x: @fruit.x * GRID_SIZE, y: @fruit.y * GRID_SIZE, w: GRID_SIZE, h: GRID_SIZE, path: 'sprites/peach.png' }.sprite
  end

  def score
    { x: 1250, y: 685, text: @score.to_s.rjust(5, '0'), size_enum: 18,
      alignment_enum: 2, r: 47, g: 79, b: 79, a: 255, vertical_alignment_enum: 1,
      font: SECONDARY_FONT }
  end

  def text(str, y_offset = 0, size_enum = 2)
    { x: GRID_CENTER, y: GRID_MIDDLE + y_offset, text: str, size_enum: size_enum,
      alignment_enum: 1, r: 155, g: 50, b: 50, a: 255, vertical_alignment_enum: 1,
      font: PRIMARY_FONT }
  end

  def head
    [@logical_x, @logical_y]
  end
end


MAX_MOVE_TICKS = 15
MIN_MOVE_TICKS = 3
MOVE_MAX_LENGTH = 30
POINTS = [500, 250, 200, 150, 100, 75, 50, 25, 10, 5, 3, 2, 1]
MAX_POINT_TICKS = 600
PRIMARY_FONT = 'fonts/BLKCHCRY.TTF'
SECONDARY_FONT = 'fonts/MayflowerAntique.ttf'
CLOUD_CHANCE = 0.003
STARTING_CLOUDS = 3

class Game
  include Numbers

  def initialize
    @menu = Menu.new
    @menu.drop!
    @map = Map.new
    @wyrm = Wyrm.new

    reset
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
      @wyrm.handle_input
      @wyrm.handle_move
      handle_collisions
      handle_fruit(args)
    end

    args.outputs.background_color = [135, 206, 250]
    args.outputs.primitives << to_p
  end

  def handle_collisions
    if @wyrm.crashed_into_self?
      # we crashed into ourselves
      puts "Crashed into ourselves"
      @state = :game_over
    elsif @map.wall?(@wyrm.logical_x, @wyrm.logical_y)
      # we crashed into a wall
      puts "Crashed into a wall"
      @state = :game_over
    end
  end

  def handle_fruit(args)
    return unless @wyrm.head == @fruit

    @wyrm.grow
    points = [POINTS[(args.easing.ease(0, args.tick_count - @fruit_tick, MAX_POINT_TICKS, :identity) * POINTS.length).round].to_i, 1].max
    @score += points
    label = FruitScoreLabel.new(@wyrm.logical_x * GRID_SIZE + GRID_SIZE / 2, @wyrm.logical_y * GRID_SIZE, points.to_s, 5)
    label.animate
    @animations << label
    @fruit = random_fruit
    @fruit_tick = args.tick_count
  end

  def handle_menu(args)
    if args.inputs.keyboard.key_up.space
      reset
      @state = :game_starting
    end
  end

  def random_fruit
    found = false
    begin
      pos = [rand(GRID_WIDTH), rand(GRID_HEIGHT)]
      found = true unless @map.wall?(pos.x, pos.y) || @wyrm.include?(pos)
    end while !found
    pos
  end

  def reset
    @state = :new_game
    @score = 0
    @animations = []
    @wyrm.reset
    @fruit = random_fruit
    STARTING_CLOUDS.times { @animations << Cloud.new }
  end

  def to_p
    case @state
    when :new_game, :game_starting
      @menu.to_p
    when :menu_rising
      [@map.to_p, @wyrm.to_p, fruit_sprite, score, @menu.to_p]
    when :game
      @animations.reject!(&:finished?)
      @animations << Cloud.new(anywhere: false) if rand < CLOUD_CHANCE
      [@map.to_p] + @wyrm.to_p + [fruit_sprite, score] + @animations.map(&:to_p)
    when :game_over
      [text('GAME OVER'), text('Press [SPACE] to play again', -50), score]
    end
  end

  def fruit_sprite
    { x: @fruit.x * GRID_SIZE, y: @fruit.y * GRID_SIZE, w: GRID_SIZE, h: GRID_SIZE, path: 'sprites/peach2.png' }.sprite!
  end

  def score
    draw_number(1100, 664, @score.to_s.rjust(5, '0'))
    # { x: 1250, y: 685, text: @score.to_s.rjust(5, '0'), size_enum: 18,
    #   alignment_enum: 2, r: 47, g: 79, b: 79, a: 255, vertical_alignment_enum: 1,
    #   font: SECONDARY_FONT }
  end

  def text(str, y_offset = 0, size_enum = 2)
    { x: GRID_CENTER, y: GRID_MIDDLE + y_offset, text: str, size_enum: size_enum,
      alignment_enum: 1, r: 155, g: 50, b: 50, a: 255, vertical_alignment_enum: 1,
      font: PRIMARY_FONT }
  end
end


POINTS = [500, 250, 200, 150, 100, 75, 50, 25, 10, 5, 3, 2, 1]
MAX_POINT_TICKS = 600
PRIMARY_FONT = 'fonts/BLKCHCRY.TTF'
SECONDARY_FONT = 'fonts/MayflowerAntique.ttf'
CLOUD_CHANCE = 0.003
WHISP_CHANCE = 0.01
STARTING_CLOUDS = 3

class Game
  include Numbers

  def initialize
    @menu = Menu.new
    @menu.drop!
    @map = Map.new
    @wyrm = Wyrm.new
    @sky = Sky.new
    @sky.night!
    @portal = Portal.new(610, 350)
    @title_bar = TitleBar.new

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

    args.outputs.background_color = [12, 12, 12]
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
    return unless @wyrm.head == @fruit && @gem.visible?

    @wyrm.grow
    points = [POINTS[(args.easing.ease(0, args.tick_count - @fruit_tick, MAX_POINT_TICKS, :identity) * POINTS.length).round].to_i, 1].max
    @title_bar.gem_eaten(points)

    label = FruitScoreLabel.new(@wyrm.logical_x * GRID_SIZE + GRID_SIZE / 2, @wyrm.logical_y * GRID_SIZE, points.to_s, 5)
    label.animate
    @animations << label

    if @title_bar.gems_left > 0
      @fruit = random_fruit
      @gem.move_to(@fruit.x, @fruit.y)
      @fruit_tick = args.tick_count
    else
      @gem.hide!
      @portal.show!
    end
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
      pos = [rand(GRID_WIDTH), rand(GRID_HEIGHT - 1)] # the top row is reserved for the title bar
      found = true unless @map.wall?(pos.x, pos.y) || @wyrm.include?(pos)
    end while !found
    pos
  end

  def reset
    @state = :new_game
    @animations = []
    @wyrm.reset
    @fruit = random_fruit
    @gem = Gem.new(@fruit.x, @fruit.y)
    @title_bar.reset
    STARTING_CLOUDS.times { @animations << Cloud.new }
  end

  def to_p
    case @state
    when :new_game, :game_starting
      [@sky.to_p, @menu.to_p]
    when :menu_rising
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @menu.to_p, @title_bar.to_p]
    when :game
      @animations.reject!(&:finished?)
      @animations << Cloud.new(anywhere: false) if rand < CLOUD_CHANCE
      @animations << Whisp.new(rand(1200) + 40, rand(600) + 60) if rand < WHISP_CHANCE
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @animations.map(&:to_p), @portal.to_p, @title_bar.to_p]
    when :game_over
      [@sky.to_p, text('GAME OVER'), text('Press [SPACE] to play again', -50), @title_bar.to_p]
    end
  end

  def text(str, y_offset = 0, size_enum = 2)
    { x: GRID_CENTER, y: GRID_MIDDLE + y_offset, text: str, size_enum: size_enum,
      alignment_enum: 1, r: 155, g: 50, b: 50, a: 255, vertical_alignment_enum: 1,
      font: PRIMARY_FONT }
  end
end


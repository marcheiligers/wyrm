POINTS = [500, 250, 200, 150, 100, 75, 50, 25, 10, 5, 3, 2, 1]
MAX_POINT_TICKS = 600

CLOUD_CHANCE = [0.0005, 0.0008, 0.001, 0.0012, 0.0015, 0.0018, 0.002, 0.0023, 0.0025, 0.0028, 0.003, 0.0032]
WHISP_CHANCE = 0.01
STARTING_CLOUDS = 3

PORTAL_LOCATION = [14, 7]

class Game
  # States:
  # => :boot - Game has just started up
  # => :new_game - Startup menu display, menu down animation
  # => :game_starting - Menu up and map appear animations start
  # => :menu_rising - Animations continue
  # => TODO: :game_portal_exit - exiting the portal (normal game state but with partial body showing)
  # => :game_normal - Normal game play, collecting gems
  # => :game_portal_enter - Level complete, entering portal
  # => :game_over - Game over menu display
  # => TODO: :win - Win menu display
  attr_reader :state, :score, :level, :gems_left

  def initialize
    @state = :boot
  end

  def reset
    @state = :new_game
    @animations = []
    @wyrm.reset
    @portal.show!
    @score = 0
    @level = 0
    @gems_left = GEMS_PER_LEVEL

    STARTING_CLOUDS.times { @animations << Cloud.new }
  end

  def tick(args)
    case @state
    when :boot
      handle_boot
    when :new_game, :game_over
      handle_menu
    when :game_starting
      handle_game_starting
    when :menu_rising
      handle_menu_rising
    when :game_normal
      @wyrm.handle_input
      @wyrm.handle_move
      handle_collisions
      handle_portal_exit
      handle_gem
    when :game_portal_enter
      @wyrm.handle_input
      @wyrm.handle_move
      handle_collisions unless @wyrm.state == :portal_enter
      handle_portal_enter
    end

    args.outputs.background_color = [8, 32, 32]
    args.outputs.primitives << to_p
  end

  def handle_boot
    @sky = Sky.new
    @title_bar = TitleBar.new

    @wyrm = Wyrm.new
    @portal = Portal.new
    @gem = Gem.new

    reset

    @menu = Menu.new
    @menu.drop!

    @map = Map.new

    @state = :new_game
  end

  def handle_game_starting
    @menu.rise!
    @map.next_level!
    @gem.move_to(*random_gem_position)
    @state = :menu_rising
  end

  def handle_menu_rising
    @state = :game_normal if @menu.finished?
    @gem_tick = $args.tick_count
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

  def handle_gem
    return unless @wyrm.head == @gem.location && @gem.visible?

    @wyrm.grow
    points = [POINTS[($args.easing.ease(0, $args.tick_count - @gem_tick, MAX_POINT_TICKS, :identity) * POINTS.length).round].to_i, 1].max
    @score += points
    @animations << ScoreLabel.new(@wyrm.logical_x * GRID_SIZE, @wyrm.logical_y * GRID_SIZE, points)
    @gems_left -= 1

    if @gems_left > 0
      @gem.move_to(*random_gem_position)
      @gem_tick = $args.tick_count
    else
      @gem.hide!
      @portal.show!
      @state = :game_portal_enter
    end
  end

  def handle_portal_exit
    return unless @wyrm.state == :normal && @portal.visible?

    @portal.hide!
  end

  def handle_portal_enter
    return unless @portal.visible?

    if @wyrm.head == @portal.location && @wyrm.state == :normal
      @wyrm.enter_portal!
    elsif @wyrm.state == :portal_entered
      # next level or win
      if @level < Map::LEVELS.length - 1
        @level += 1
        @map.next_level!
        @state = :game_normal
        @wyrm.exit_portal!
        @gem.move_to(*random_gem_position)
        @gem_tick = $args.tick_count
        @gems_left = GEMS_PER_LEVEL
        @gem.show!
      else
        # TODO: Win!
      end
    end
  end

  def handle_menu
    if $args.inputs.keyboard.key_up.space
      reset
      @state = :game_starting
    end
  end

  def random_gem_position
    found = false
    begin
      pos = [rand(GRID_WIDTH), rand(GRID_HEIGHT - 1)] # the top row is reserved for the title bar
      found = true unless @map.wall?(pos.x, pos.y) || @wyrm.include?(pos)
    end while !found
    pos
  end

  def to_p
    @animations.reject!(&:finished?)
    @animations << Cloud.new(anywhere: false) if rand < CLOUD_CHANCE[@level]
    @animations << Whisp.new(rand(600) + 20, rand(300) + 30) if rand < WHISP_CHANCE

    case @state
    when :new_game, :game_starting
      [@sky.to_p, @menu.to_p, @title_bar.to_p]
    when :menu_rising
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @animations.map(&:to_p), @portal.to_p, @menu.to_p, @title_bar.to_p]
    when :game_normal
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @animations.map(&:to_p), @portal.to_p, @title_bar.to_p]
    when :game_portal_enter
      [@sky.to_p, @map.to_p, @wyrm.to_p, @animations.map(&:to_p), @portal.to_p, @title_bar.to_p]
    when :game_over
      [@sky.to_p, game_over, press_space, @title_bar.to_p]
    end
  end

  def game_over
    {
      x: GRID_CENTER - (140.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (20.idiv(2) * PIXEL_MUL),
      w: 140 * PIXEL_MUL,
      h: 20 * PIXEL_MUL,
      path: 'sprites/game-over.png'
    }.sprite!
  end

  def press_space
    {
      x: GRID_CENTER - (180.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (20.idiv(2) * PIXEL_MUL) - GRID_SIZE * 4,
      w: 180 * PIXEL_MUL,
      h: 20 * PIXEL_MUL,
      path: 'sprites/press-space.png'
    }.sprite!
  end
end


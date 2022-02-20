POINTS = [500, 250, 200, 150, 100, 75, 50, 25, 10, 5, 3, 2, 1]
MAX_POINT_TICKS = 600

CLOUD_CHANCE = [0.0005, 0.0008, 0.001, 0.0012, 0.0015, 0.0018, 0.002, 0.0023, 0.0025, 0.0028, 0.003, 0.0032]
WHISP_CHANCE = 0.01
STARTING_CLOUDS = 3

PORTAL_LOCATION = [14, 7]

PAUSABLE_STATES = %i[paused game_normal game_portal_enter].freeze

class Game
  # States:
  # => :boot - Game has just started up
  # => :new_game - Startup menu display, menu down animation
  # => :game_starting - Menu up and map appear animations start
  # => :menu_rising - Animations continue
  # => :game_normal - Normal game play, collecting gems
  # => :game_portal_enter - Level complete, entering portal
  # => :game_over - Game over menu display
  # => :win - Win menu display
  # => :paused - Paused
  attr_reader :state, :score, :level, :gems_left, :seen_help
  attr_accessor :sound_fx, :queue_dir_changes, :debug, :gems_per_level,
                :max_move_ticks, :min_move_ticks, :high_score, :high_level,
                :starting_level

  include InputManager

  def initialize
    @state = :boot
    @sound_fx = true

    @queue_dir_changes = true
    @debug = false
    @gems_per_level = GEMS_PER_LEVEL

    @max_move_ticks = MAX_MOVE_TICKS
    @min_move_ticks = MIN_MOVE_TICKS

    @high_score = 0
    @high_level = 0
    @starting_level = 0
  end

  def reset
    @state = :new_game
    @animations = []
    @wyrm.reset
    @score = 0
    @level = 0
    @gems_left = gems_per_level
  end

  def tick(args)
    handle_global_input

    case @state
    when :boot
      handle_boot
    when :new_game
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
    when :paused
      # part of global_input
    when :game_over, :win
      reset if accept? && $args.tick_count - @death_ticks > 30
      @current_menu.drop!
    when :game_portal_enter
      @wyrm.handle_input
      @wyrm.handle_move
      handle_collisions unless @wyrm.state == :portal_enter || @wyrm.state == :portal_entered
      handle_portal_enter
    end

    args.outputs.background_color = [8, 32, 32]
    args.outputs.primitives << to_p
    args.outputs.primitives << debug_p if debug
  end

  def handle_boot
    @sky = Sky.new
    @title_bar = TitleBar.new

    @wyrm = Wyrm.new
    @portal = Portal.new
    @gem = Gem.new

    reset

    @menu = Menu.new
    @current_menu = @menu
    @current_menu.drop!

    @map = Map.new

    @state = :new_game

    $args.audio[:theme] = {
      input: 'sounds/theme1.ogg', # Filename
      x: 0.0, y: 0.0, z: 0.0,     # Relative position to the listener, x, y, z from -1.0 to 1.0
      gain: 0.3,                  # Volume (0.0 to 1.0)
      pitch: 1.0,                 # Pitch of the sound (1.0 = original pitch)
      paused: false,              # Set to true to pause the sound at the current playback position
      looping: true               # Set to true to loop the sound/music until you stop it
    }

    options = $gtk.parse_json_file('options.json')
    return unless options

    @sound_fx = options['sound_fx']
    music(options['music'])
    @seen_help = options['seen_help']
    @high_score = options['high_score'].to_i
    @high_level = options['high_level'].to_i
    @starting_level = options['starting_level'].to_i
  end

  def handle_global_input
    if PAUSABLE_STATES.include?(@state) && ($args.inputs.keyboard.key_down.p || $args.controller_one.key_down.start)
      if paused?
        @state = @unpaused_state
      else
        @unpaused_state = @state
        @state = :paused
      end
    end

    changed = true && music(!music?) if $args.inputs.keyboard.key_down.m
    changed = true && @sound_fx = !sound_fx? if $args.inputs.keyboard.key_down.n

    write_options if changed
  end

  def seen_help!
    @seen_help = true
    write_options
  end

  def seen_help?
    @seen_help
  end

  def write_options
    data = [
      json_string('music', music?),
      json_string('sound_fx', sound_fx?),
      json_string('seen_help', seen_help?),
      json_string('high_score', high_score),
      json_string('high_level', high_level),
      json_string('starting_level', starting_level)
    ].join(',')
    $gtk.write_file('options.json', "{#{data}}")
  end

  def json_string(key, val)
    "\"#{key}\":#{val}"
  end

  def sound_fx?
    sound_fx
  end

  def music?
    !$args.audio[:theme].paused
  end

  def music(on_off)
    $args.audio[:theme].paused = !on_off
  end

  def paused?
    @state == :paused
  end

  def handle_game_starting
    @level = @starting_level
    @current_menu.rise!
    @map.next_level!
    @gem.move_to(*random_gem_position)
    @gems_left = gems_per_level
    @portal.show!
    @wyrm.reset
    @state = :menu_rising
    write_options
    STARTING_CLOUDS.times { @animations << Cloud.new }
  end

  def handle_menu_rising
    @state = :game_normal if @current_menu.finished?
    @gem_ticks = 0
  end

  def handle_collisions
    if @wyrm.crashed_into_self?
      # we crashed into ourselves
      puts "Crashed into ourselves"
      @state = :game_over
      @death_ticks = $args.tick_count
      @current_menu.reset
      $args.outputs.sounds << 'sounds/crash1.wav' if $game.sound_fx
      @high_score = @score if @score > @high_score
      @high_level = @level if @level > @high_level
      write_options
    elsif @map.wall?(@wyrm.logical_x, @wyrm.logical_y)
      # we crashed into a wall
      puts "Crashed into a wall"
      @state = :game_over
      @death_ticks = $args.tick_count
      @current_menu.reset
      # eJxjYtj-UN6UkSNNa_snBjBoqGdgWM-gzlTB-r_-vz1jqS1EkNsYQp_xgdAzIlH5MDpNDWrIOnYj44kMh1oYGG0gIu_9IDTja60pIiCGFEffKxDNpK_99wOI8SzX-TWIzmQ3_A6i73Es4gHRcY43hMDykhAT_kOgPMQNdAMACQ04sA..
      # louder: eJxjYtj-UN6UkSNNa_snBjBoqGdgWM-gzlTB-r_-vz1jqS1EkNsYQp_xgdAzIlH5MDpNDWrIOnYj44kMh1oYGG0gIu_9IDTja60pIiCGFEffKxDNpK_99wOI8SzX-TWIzmQ3_A6i73Es4gHRcY43hMDykhAT_kOg_P96BnoCAEYKOT0.
      $args.outputs.sounds << 'sounds/crash1.wav' if $game.sound_fx
      @high_score = @score if @score > @high_score
      @high_level = @level if @level > @high_level
      write_options
    end
  end

  def handle_gem
    @gem_ticks += 1
    return unless @wyrm.head == @gem.location && @gem.visible?

    $args.outputs.sounds << 'sounds/gem2.wav' if $game.sound_fx
    @wyrm.grow
    points = [POINTS[($args.easing.ease(0, @gem_ticks, MAX_POINT_TICKS, :identity) * POINTS.length).round].to_i, 1].max
    @score += points
    @animations << ScoreLabel.new(@wyrm.logical_x * GRID_SIZE, @wyrm.logical_y * GRID_SIZE, points)
    @gems_left -= 1

    if @gems_left > 0
      @gem.move_to(*random_gem_position)
      @gem_ticks = 0
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
        @gem_ticks = 0
        @gems_left = gems_per_level
        @gem.show!
      else
        @state = :win
        @death_ticks = $args.tick_count
        @current_menu.reset
        @high_score = @score if @score > @high_score
        @high_level = @level if @level > @high_level
        write_options
      end
    end
  end

  def handle_menu
    @current_menu.handle_input
    @state = @current_menu.new_state if @current_menu.new_state?
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

    case @state
    when :new_game, :game_starting
      [@sky.to_p, @current_menu.to_p, @animations.map(&:to_p), @title_bar.to_p]
    when :menu_rising
      randoms
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @animations.map(&:to_p), @portal.to_p, @current_menu.to_p, @title_bar.to_p]
    when :paused
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @animations.map(&:to_p), @portal.to_p, paused_screen, @title_bar.to_p]
    when :game_normal
      randoms
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @animations.map(&:to_p), @portal.to_p, @title_bar.to_p]
    when :game_portal_enter
      randoms
      [@sky.to_p, @map.to_p, @wyrm.to_p, @animations.map(&:to_p), @portal.to_p, @title_bar.to_p]
    when :game_over
      randoms
      [@sky.to_p, @map.to_p, @wyrm.to_p, @gem.to_p, @animations.map(&:to_p), game_over_screen, @title_bar.to_p]
    when :win
      randoms
      [@sky.to_p, @map.to_p, @animations.map(&:to_p), you_win_screen, @title_bar.to_p]
    end
  end

  def randoms
    @animations << Cloud.new(anywhere: false) if rand < CLOUD_CHANCE[@level]
    @animations << Whisp.new(rand(600) + 20, rand(300) + 30) if rand < WHISP_CHANCE
  end

  def game_over_screen
    [ overlay, game_over, press_space ]
  end

  def game_over
    @game_over ||= {
      x: GRID_CENTER - (140.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (20.idiv(2) * PIXEL_MUL),
      w: 140 * PIXEL_MUL,
      h: 20 * PIXEL_MUL,
      path: 'sprites/game-over.png'
    }.sprite!
  end

  def you_win_screen
    [ overlay, you_win, press_space ]
  end

  def you_win
    @you_win ||= {
      x: GRID_CENTER - (110.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (20.idiv(2) * PIXEL_MUL),
      w: 110 * PIXEL_MUL,
      h: 20 * PIXEL_MUL,
      path: 'sprites/you-win.png'
    }.sprite!
  end

  def press_space
    @press_space ||= {
      x: GRID_CENTER - (180.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (20.idiv(2) * PIXEL_MUL) - GRID_SIZE * 4,
      w: 180 * PIXEL_MUL,
      h: 20 * PIXEL_MUL,
      path: 'sprites/press-space.png'
    }.sprite!
  end

  def paused_text
    @paused_text ||= {
      x: GRID_CENTER - (80.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (10.idiv(2) * PIXEL_MUL) - GRID_SIZE * 2,
      w: 80 * PIXEL_MUL,
      h: 10 * PIXEL_MUL,
      path: 'sprites/paused.png'
    }.sprite!
  end

  def paused_screen
    [overlay, paused_text]
  end

  def overlay
    @overlay ||= {
      x: 0,
      y: 0,
      w: 1280,
      h: 720 - GRID_SIZE,
      r: 0,
      g: 0,
      b: 0,
      a: 100
    }.solid!
  end

  def debug_p
    [].tap do |p|
      p << { x: 1260, y: 720, text: $args.gtk.current_framerate.round.to_s, r: 255, g: 255, b: 255 }.label!
      p << { x: 1260, y: 700, text: 'Q', r: 255, g: 255, b: 255 }.label! if @queue_dir_changes
      p << { x: 0, y: 720, text: min_move_ticks, r: 255, g: 255, b: 255 }.label!
      p << { x: 0, y: 700, text: max_move_ticks, r: 255, g: 255, b: 255 }.label!
      p << { x: 20, y: 720, text: @wyrm.move_ticks, r: 255, g: 255, b: 255 }.label!
      p << { x: 20, y: 700, text: @wyrm.current_move_ticks, r: 255, g: 255, b: 255 }.label!
    end
  end
end

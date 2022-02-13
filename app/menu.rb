class Menu < MenuBase
  class Selection < Dynamic
    def initialize
      selection = {
        x: GRID_CENTER - (80.idiv(2) * PIXEL_MUL),
        y: 0,
        w: 80 * PIXEL_MUL,
        h: 20 * PIXEL_MUL,
        path: 'sprites/selection.png'
      }.sprite!
      super(selection)
      select(1)
    end

    def select(pos)
      @pos = pos
      @y = GRID_MIDDLE + (20.idiv(2) * PIXEL_MUL) - GRID_SIZE * (pos * 2 + 3)
    end

    def selected
      @pos
    end
  end

  class Animated
    def initialize(thing)
      @thing = thing
    end

    def to_p(dy)
      if @thing.is_a?(Array)
        @thing.to_p.map do |sprite|
          sprite.tap { |temp| temp[:y] += dy }
        end
      else
        @thing.to_p.tap do |sprite|
          sprite[:y] += dy
        end
      end
    end
  end

  class SwitchLabel < Dynamic
    def initialize(name, y, on_off)
      @switch = {
        x: GRID_CENTER - (60.idiv(2) * PIXEL_MUL),
        y: GRID_MIDDLE + (10.idiv(2) * PIXEL_MUL) - GRID_SIZE * y,
        w: 60 * PIXEL_MUL,
        h: 10 * PIXEL_MUL,
        source_y: 0,
        source_w: 60,
        source_h: 10,
        path: "sprites/label-#{name}.png"
      }.sprite!

      super(@switch)
      set(on_off)
    end

    def set(on_off)
      @on_off = on_off
      @switch.merge!(source_x: on_off ? 0 : 60)
    end

    def selected
      @pos
    end
  end

  attr_reader :new_state

  include InputManager

  def initialize
    super('title')
    add_static({ x: 390, y: 320, w: 512, h: 128, path: 'sprites/title.png' }.sprite!)
    reset
  end

  def reset
    @new_state = nil
    main_submenu
  end

  def main_submenu
    clear_dynamics

    @selection = Selection.new
    add_dynamic(@selection)

    add_dynamic(Dynamic.new(label('play', 4)))
    add_dynamic(Dynamic.new(label('options', 6)))
    add_dynamic(Dynamic.new(label('help', 8)))

    @submenu = :main
  end

  def options_submenu
    clear_dynamics

    @selection = Selection.new
    add_dynamic(@selection)

    @sound_fx = SwitchLabel.new('sound-fx', 4, $game.sound_fx)
    add_dynamic(@sound_fx)
    @music = SwitchLabel.new('music', 6, $game.music?)
    add_dynamic(@music)
    add_dynamic(Dynamic.new(label('back', 8)))

    @submenu = :options
  end

  def help_submenu_2(mode = :help_2)
    clear_dynamics

    @selection = Selection.new
    add_dynamic(@selection)
    @selection.select(3)

    add_dynamic(Dynamic.new(instructions_1))
    add_dynamic(Animated.new(HoldAnim.new))
    add_dynamic(Animated.new(DirectionKeysAnim.new))
    if mode == :help_2
      add_dynamic(Dynamic.new(label('back', 8)))
    else
      add_dynamic(Dynamic.new(label('play', 8)))
    end

    @submenu = mode
  end

  def help_submenu_1(mode = :help_1)
    clear_dynamics

    @selection = Selection.new
    add_dynamic(@selection)
    @selection.select(3)

    add_dynamic(Dynamic.new(instructions_2))
    add_dynamic(Animated.new(Gem.new(18, 7)))
    add_dynamic(Animated.new(Portal.new(21, 3, true)))
    add_dynamic(Animated.new(HeadSprite.new([20, 4])))
    add_dynamic(Animated.new(WingsSprite.new([20, 4])))
    add_dynamic(Animated.new(BodySprite.new([19, 4], :right)))
    add_dynamic(Animated.new(BodySprite.new([18, 4], :right)))
    add_dynamic(Animated.new(BodySprite.new([17, 4], :down)))
    add_dynamic(Animated.new(BodySprite.new([17, 5], :right)))
    add_dynamic(Animated.new(BodySprite.new([16, 5], :right)))
    add_dynamic(Animated.new(BodySprite.new([15, 5], :right, true)))
    add_dynamic(Dynamic.new(label('next', 8)))

    @submenu = mode
  end

  def show_help_before_play_1
    help_submenu_1(:show_help_before_play_1)
  end

  def label(name, y)
    {
      x: GRID_CENTER - (60.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (10.idiv(2) * PIXEL_MUL) - GRID_SIZE * y,
      w: 60 * PIXEL_MUL,
      h: 10 * PIXEL_MUL,
      path: "sprites/label-#{name}.png"
    }.sprite!
  end

  def instructions_1
    {
      x: GRID_CENTER - (200.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (40.idiv(2) * PIXEL_MUL) - GRID_SIZE * 7,
      w: 200 * PIXEL_MUL,
      h: 40 * PIXEL_MUL,
      source_x: 0,
      source_y: 0,
      source_w: 200,
      source_h: 40,
      path: 'sprites/instructions.png'
    }.sprite!
  end

  def instructions_2
    {
      x: GRID_CENTER - (200.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (40.idiv(2) * PIXEL_MUL) - GRID_SIZE * 7,
      w: 200 * PIXEL_MUL,
      h: 40 * PIXEL_MUL,
      source_x: 200,
      source_y: 0,
      source_w: 200,
      source_h: 40,
      path: 'sprites/instructions.png'
    }.sprite!
  end

  def handle_input
    dir = direction_down
    accept = accept?

    case @submenu
    when :main
      @selection.select([@selection.selected - 1, 1].max) if dir == :up
      @selection.select([@selection.selected + 1, 3].min) if dir == :down
      if accept
        case @selection.selected
        when 1
          if $game.seen_help?
            @new_state = :game_starting
          else
            show_help_before_play_1
          end
        when 2
          options_submenu
        when 3
          help_submenu_1
        end
      end
    when :options
      @selection.select([@selection.selected - 1, 1].max) if dir == :up
      @selection.select([@selection.selected + 1, 3].min) if dir == :down

      # "Cheats"
      key_down = $args.inputs.keyboard.key_down
      $game.queue_dir_changes = !$game.queue_dir_changes if key_down.q
      $game.debug = !$game.debug if key_down.d
      $game.gems_per_level = ($game.gems_per_level % GEMS_PER_LEVEL) + 1 if key_down.g
      $game.max_move_ticks = [$game.max_move_ticks + 1, 60].min if key_down.close_square_brace
      $game.max_move_ticks = [$game.max_move_ticks - 1, 1].max if key_down.open_square_brace
      $game.min_move_ticks = [$game.min_move_ticks + 1, 60].min if key_down.close_curly_brace
      $game.min_move_ticks = [$game.min_move_ticks - 1, 1].max if key_down.open_curly_brace
      $game.min_move_ticks = $game.max_move_ticks if $game.min_move_ticks > $game.max_move_ticks

      if accept
        case @selection.selected
        when 1
          $game.sound_fx = !$game.sound_fx?
          @sound_fx.set($game.sound_fx?)
        when 2
          $game.music(!$game.music?)
          @music.set($game.music?)
        when 3
          main_submenu
        end
        $game.write_options
      end
    when :help_1
      help_submenu_2 if accept
    when :help_2
      if accept
        $game.seen_help!
        main_submenu
      end
    when :show_help_before_play_1
      help_submenu_2(:show_help_before_play_2) if accept
    when :show_help_before_play_2
      if accept
        $game.seen_help!
        @new_state = :game_starting
      end
    end

    main_submenu if reject?
    $args.outputs.sounds << 'sounds/menu1.wav' if $game.sound_fx && (dir || accept)
  end

  def new_state?
    !@new_state.nil?
  end
end

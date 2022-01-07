class Menu < MenuBase
  class Selection < Dynamic
    def initialize
      selection = {
                    x: GRID_CENTER - (80.idiv(2) * PIXEL_MUL),
                    y: 0,
                    w: 80 * PIXEL_MUL,
                    h: 20 * PIXEL_MUL,
                    path: "sprites/selection.png"
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

  def initialize
    super('title')
    add_static({ x: 390, y: 320, w: 512, h: 128, path: 'sprites/title.png' }.sprite!)
    main_submenu
  end

  def reset
    @new_state = nil
  end

  def main_submenu
    clear_dynamics

    add_dynamic(Dynamic.new(label('play', 4)))
    add_dynamic(Dynamic.new(label('options', 6)))
    add_dynamic(Dynamic.new(label('help', 8)))

    @selection = Selection.new
    add_dynamic(@selection)

    @submenu = :main
  end

  def options_submenu
    clear_dynamics

    @sound_fx = SwitchLabel.new('sound-fx', 4, $game.sound_fx)
    add_dynamic(@sound_fx)
    @music = SwitchLabel.new('music', 6, $game.music?)
    add_dynamic(@music)
    add_dynamic(Dynamic.new(label('back', 8)))

    @selection = Selection.new
    add_dynamic(@selection)

    @submenu = :options
  end

  def help_submenu
    clear_dynamics

    add_dynamic(Dynamic.new(instructions))
    add_dynamic(Dynamic.new(label('back', 8)))

    @selection = Selection.new
    add_dynamic(@selection)
    @selection.select(3)

    @submenu = :help
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

  def instructions
    {
      x: GRID_CENTER - (200.idiv(2) * PIXEL_MUL),
      y: GRID_MIDDLE + (40.idiv(2) * PIXEL_MUL) - GRID_SIZE * 7,
      w: 200 * PIXEL_MUL,
      h: 40 * PIXEL_MUL,
      path: 'sprites/instructions.png'
    }.sprite!
  end

  def handle_input
    case @submenu
    when :main
      @selection.select([@selection.selected - 1, 1].max) if $args.inputs.keyboard.key_down.up
      @selection.select([@selection.selected + 1, 3].min) if $args.inputs.keyboard.key_down.down
      if $args.inputs.keyboard.key_down.enter
        case @selection.selected
        when 1
          @new_state = :game_starting
        when 2
          options_submenu
        when 3
          help_submenu
        end
      end
    when :options
      @selection.select([@selection.selected - 1, 1].max) if $args.inputs.keyboard.key_down.up
      @selection.select([@selection.selected + 1, 3].min) if $args.inputs.keyboard.key_down.down
      $game.queue_dir_changes = !$game.queue_dir_changes if $args.inputs.keyboard.key_down.q
      if $args.inputs.keyboard.key_down.enter
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
      end
    when :help
      main_submenu if $args.inputs.keyboard.key_down.enter
    end
  end

  def new_state?
    !@new_state.nil?
  end

  def new_state
    @new_state
  end
end
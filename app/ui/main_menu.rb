class MainMenu < VerticalMenu
  class GameElement < Image
    def initialize(**args)
      super(args)
      @child = args[:child]
    end

    def to_primitives
      @child.to_p
    end
  end

  class StartLevel < Image
    include Numbers

    def to_primitives
      draw_number(GRID_CENTER + GRID_SIZE * 2, GRID_MIDDLE - GRID_SIZE * 5, ($game.starting_level + 1).to_s)
    end
  end

  attr_reader :new_state

  def initialize
    super(
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      visible: false,
      background: create_background,
      color: Color::TRANSPARENT,
      focus_rect: GraphicalFocusRect.new(w: 320, h: 80, path: 'sprites/selection.png'),
      focus_rect_front: false,
      text: 'Main Menu'
    )

    reset
  end

  def reset
    @new_state = nil
    main_submenu
  end

  def main_submenu
    children.clear
    focus_rect.focus(add_item(GraphicalButton.new(y: 240, w: 240, h: 40, path: 'sprites/label-play.png', text: 'Play')))
    add_item(GraphicalButton.new(y: 150, w: 240, h: 40, path: 'sprites/label-options.png', text: 'Options'))
    add_item(GraphicalButton.new(y: 60, w: 240, h: 40, path: 'sprites/label-help.png', text: 'Help'))
    @state = :main
  end

  def options_submenu
    children.clear
    focus_rect.focus(add_item(GraphicalSwitch.new(y: 240, w: 240, h: 40, source_w: 60, path: 'sprites/label-sound-fx.png', on: $game.sound_fx, text: 'Sound FX')))
    add_item(GraphicalSwitch.new(y: 150, w: 240, h: 40, source_w: 60, path: 'sprites/label-music.png', on: $game.music?, text: 'Music'))
    add_item(GraphicalButton.new(y: 60, w: 240, h: 40, path: 'sprites/label-back.png', text: 'Back'))

    @state = :options
  end

  def help_1_submenu(mode = :help_1)
    children.clear

    add_static(Sprite.new(y: GRID_MIDDLE + (40.idiv(2) * PIXEL_MUL) - GRID_SIZE * 7, w: 200 * PIXEL_MUL, h: 40 * PIXEL_MUL, path: 'sprites/instructions.png', frame_w: 200, frame: 2))
    add_static(GameElement.new(child: Coin.new(18, 7)))
    add_static(GameElement.new(child: Portal.new(21, 3, true)))
    add_static(GameElement.new(child: HeadSprite.new([20, 4])))
    add_static(GameElement.new(child: WingsSprite.new([20, 4])))
    add_static(GameElement.new(child: BodySprite.new([19, 4], :right)))
    add_static(GameElement.new(child: BodySprite.new([18, 4], :right)))
    add_static(GameElement.new(child: BodySprite.new([17, 4], :down)))
    add_static(GameElement.new(child: BodySprite.new([17, 5], :right)))
    add_static(GameElement.new(child: BodySprite.new([16, 5], :right)))
    add_static(GameElement.new(child: BodySprite.new([15, 5], :right, true)))

    focus_rect.focus(add_item(GraphicalButton.new(y: 60, w: 240, h: 40, path: 'sprites/label-next.png', text: 'Next')))

    @state = mode
  end

  def help_2_submenu(mode = :help_2)
    children.clear

    add_static(Sprite.new(y: GRID_MIDDLE + (40.idiv(2) * PIXEL_MUL) - GRID_SIZE * 7, w: 200 * PIXEL_MUL, h: 40 * PIXEL_MUL, path: 'sprites/instructions.png', frame_w: 200, frame: 1))
    add_static(GameElement.new(child: HoldAnim.new))
    add_static(GameElement.new(child: DirectionKeysAnim.new))

    if mode == :help_2
      focus_rect.focus(add_item(GraphicalButton.new(y: 60, w: 240, h: 40, path: 'sprites/label-back.png', text: 'Back')))
    else
      focus_rect.focus(add_item(GraphicalButton.new(y: 60, w: 240, h: 40, path: 'sprites/label-play.png', text: 'Play')))
    end


    @state = mode
  end

  def level_select_submenu
    children.clear

    width = ($game.high_level + 1) * 10
    left = GRID_CENTER - (width * PIXEL_MUL).idiv(2)
    top = GRID_MIDDLE - GRID_SIZE * 3
    ($game.high_level + 1).times do |i|
      elem = GraphicalButton.new(x: left + 10 * PIXEL_MUL * i, y: top, w: 10 * PIXEL_MUL, h: 10 * PIXEL_MUL, path: 'sprites/number_keys.png', frame_w: 10, frame: i + 1, text: (i + 1).to_s)
      add_static(elem).attach_observer(self, :observe_level)
    end

    elem = GraphicalButton.new(x: GRID_CENTER - GRID_SIZE * 5, y: GRID_MIDDLE - GRID_SIZE * 5, w: 10 * PIXEL_MUL, h: 10 * PIXEL_MUL, path: 'sprites/number_keys.png', frame_w: 10, frame: 11, text: '<')
    add_static(elem).attach_observer(self, :observe_level)

    elem = GraphicalButton.new(x: GRID_CENTER + GRID_SIZE * 4, y: GRID_MIDDLE - GRID_SIZE * 5, w: 10 * PIXEL_MUL, h: 10 * PIXEL_MUL, path: 'sprites/number_keys.png', frame_w: 10, frame: 12, text: '>')
    add_static(elem).attach_observer(self, :observe_level)

    add_static(Image.new(x: GRID_CENTER - GRID_SIZE * 3, y: GRID_MIDDLE - GRID_SIZE * 5, w: GRID_SIZE * 4, h: GRID_SIZE, path: 'sprites/level.png'))

    add_static(StartLevel.new)
    focus_rect.focus(add_item(GraphicalButton.new(y: 60, w: 240, h: 40, path: 'sprites/label-play.png', text: 'Play')))

    @state = :level_select
  end

  def observe(event)
    super(event)

    if event.name == :pressed
      case event.target.text
      when 'Play'
        if @state == :level_select || @state == :help_before_play_2
          @new_state = :game_starting
        elsif $game.seen_help?
          if $game.high_level > 0
            level_select_submenu
          else
            @new_state = :game_starting
          end
        else
          help_1_submenu(:help_before_play_1)
        end
        menu_sound
      when 'Options'
        options_submenu
        menu_sound
      when 'Sound FX'
        $game.sound_fx = !$game.sound_fx?
        event.target.set($game.sound_fx?)
        menu_sound
      when 'Music'
        $game.music(!$game.music?)
        event.target.set($game.music?)
        menu_sound
      when 'Back'
        main_submenu
        menu_sound
      when 'Help'
        help_1_submenu
        menu_sound
      when 'Next'
        help_2_submenu if @state == :help_1
        help_2_submenu(:help_before_play_2) if @state == :help_before_play_1
        $game.seen_help!
        menu_sound
      end
    end

    menu_sound if event.name == :focussed
  end

  def observe_level(event)
    case event.name
    when :mouse_enter
      event.target.focus
    when :pressed
      case event.target.text
      when '>'
        $game.starting_level = [$game.starting_level + 1, $game.high_level].min
        menu_sound
      when '<'
        $game.starting_level = [$game.starting_level - 1, 0].max
        menu_sound
      else
        set_starting_level(event.target.text.to_i)
      end
    end
  end

  def handle_inputs
    super

    return unless @state == :level_select

    case direction_down
    when :right
      $game.starting_level = [$game.starting_level + 1, $game.high_level].min
      menu_sound
    when :left
      $game.starting_level = [$game.starting_level - 1, 0].max
      menu_sound
    end

    set_starting_level(number_down)
  end

  def set_starting_level(num)
    return if num.nil? || num == 0

    num = num == 0 ? 9 : num - 1 # shifting left one (zero-based)
    $game.starting_level = num if $game.high_level >= num

    menu_sound
  end

  def menu_sound
    $args.outputs.sounds << 'sounds/menu1.wav' if $game.sound_fx?
  end

  def create_background
    $args.render_target(:menu_bg).primitives << [
      { x: 390, y: 320, w: 512, h: 128, path: 'sprites/title.png' }.sprite!,
      { x: 40, y: 11 * GRID_SIZE, w: 300 * PIXEL_MUL, h: 60 * PIXEL_MUL, path: 'sprites/menu_top5.png' }.sprite!,
      { x: GRID_SIZE, y: 1 * GRID_SIZE, w: 100 * PIXEL_MUL, h: 100 * PIXEL_MUL, path: 'sprites/menu_corner5.png', flip_horizontally: true  }.sprite!,
      { x: 1280 - GRID_SIZE - 100 * PIXEL_MUL, y: 1 * GRID_SIZE, w: 100 * PIXEL_MUL, h: 100 * PIXEL_MUL, path: 'sprites/menu_corner5.png'}.sprite!
    ]

    :menu_bg
  end

  def levels
    width = ($game.high_level + 1) * 10

    {
      x: GRID_CENTER - (width * PIXEL_MUL).idiv(2),
      y: GRID_MIDDLE - GRID_SIZE * 3,
      w: width * PIXEL_MUL,
      h: 10 * PIXEL_MUL,
      source_w: width,
      path: 'sprites/number_keys.png'
    }.sprite!
  end
end

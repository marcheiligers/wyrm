class Menu
  include Easing

  TARGET = :menu
  # states: hidden, dropping, visible, rising

  def initialize
    @state = :hidden
  end

  def drop!
    @state = :dropping
    @start = $args.tick_count
  end

  def rise!
    @state = :rising
    @start = $args.tick_count
  end

  def text(str, y_offset = 0, size_enum = 2, font = PRIMARY_FONT)
    { x: GRID_CENTER, y: GRID_MIDDLE + y_offset, text: str, size_enum: size_enum,
      alignment_enum: 1, r: 47, g: 79, b: 79, a: 255, vertical_alignment_enum: 1,
      font: font }.label
  end

  SPLINE = [[0.34, 1.56, 0.64, 1], [1.0, 1.0,  1.0,  1.0], [1.0, 1.0,  1.0,  1.0]]
  DROP_DURATION = 75
  RISE_DURATION = 45

  def to_p
    @primitive ||= begin
      rt = $args.render_target(TARGET)

      rt.primitives << { x: 75, y: 75, w: 1130, h: 570, r: 142, g: 199, b: 241, a: 200 }.solid!

      rt.primitives << { x: 50, y: 500, w: 1180, h: 218, path: 'sprites/menu_top2.png' }.sprite!
      rt.primitives << { x: 15, y: 15, w: 400, h: 400, path: 'sprites/menu_corner2.png' }.sprite!
      rt.primitives << { x: 865, y: 15, w: 400, h: 400, path: 'sprites/menu_corner2.png', flip_horizontally: true }.sprite!

      rt.primitives << { x: 390, y: 360, w: 512, h: 128, path: 'sprites/title.png' }.sprite!

      # to_play = PixelFont.new('Press [SPACE] to play', 3)
      # rt.primitives << to_play.draw_at(640 - to_play.width / 2, 240)

      rt.primitives << [text('Press [SPACE] to play', -50, 3, SECONDARY_FONT)]

      { x: 0, y: 0, w: 1280, h: 720, path: TARGET, source_x: 0, source_y: 0, source_w: 1280, source_h: 720 }.sprite!
    end

    case @state
    when :visible
      @primitive.merge!(y: 0)
    when :dropping
      ticks = $args.tick_count - @start
      @state = :visible if ticks >= DROP_DURATION
      @primitive.merge!(y: (1 - ease_out_elastic(ticks, DROP_DURATION)) * 720)
    when :rising
      ticks = $args.tick_count - @start
      @state = :hidden if ticks >= RISE_DURATION
      @primitive.merge!(y: ease_in_back(ticks, RISE_DURATION) * 720)
    else
      @primitive.merge!(y: -720)
    end
  end

  def finished?
    @state == :hidden || @state == :visible
  end
end
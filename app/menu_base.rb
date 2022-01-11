class MenuBase
  include Easing

  class Dynamic
    def initialize(primitive)
      @primitive = primitive
      @y = primitive[:y]
    end

    def to_p(dy)
      @primitive.merge(y: @y + dy)
    end
  end

  DROP_DURATION = 75
  RISE_DURATION = 45

  # states: hidden, dropping, visible, rising

  def initialize(name)
    @target = "menu:#{name}"
    @state = :hidden
    @static_contents = []
    @dynamic_contents = []
  end

  def clear_dynamics
    @dynamic_contents = []
  end

  def handle_input
  end

  def new_state?
    false
  end

  def new_state
    nil
  end

  def add_static(item)
    @static_contents << item
  end

  def add_dynamic(item)
    @dynamic_contents << item
  end

  def drop!
    @state = :dropping
    @start = $args.tick_count
  end

  def rise!
    @state = :rising
    @start = $args.tick_count
  end

  def to_p
    @primitive ||= begin
      rt = $args.render_target(@target)

      rt.primitives << { x: 40, y: 11 * GRID_SIZE, w: 300 * PIXEL_MUL, h: 60 * PIXEL_MUL, path: 'sprites/menu_top5.png' }.sprite!
      rt.primitives << { x: GRID_SIZE, y: 1 * GRID_SIZE, w: 100 * PIXEL_MUL, h: 100 * PIXEL_MUL, path: 'sprites/menu_corner5.png', flip_horizontally: true  }.sprite!
      rt.primitives << { x: 1280 - GRID_SIZE - 100 * PIXEL_MUL, y: 1 * GRID_SIZE, w: 100 * PIXEL_MUL, h: 100 * PIXEL_MUL, path: 'sprites/menu_corner5.png'}.sprite!

      @static_contents.each do |item|
        rt.primitives << item
      end

      { x: 0, y: 0, w: 1280, h: 720, path: @target, source_x: 0, source_y: 0, source_w: 1280, source_h: 720 }.sprite!
    end

    y = case @state
        when :visible
          0
        when :dropping
          ticks = $args.tick_count - @start
          @state = :visible if ticks >= DROP_DURATION
          (1 - ease_out_elastic(ticks, DROP_DURATION)) * 720
        when :rising
          ticks = $args.tick_count - @start
          @state = :hidden if ticks >= RISE_DURATION
          ease_in_back(ticks, RISE_DURATION) * 720
        else
          720
        end

    [@primitive.merge!(y: y), @dynamic_contents.map { |item| item.to_p(y) }]
  end

  def finished?
    @state == :hidden || @state == :visible
  end
end
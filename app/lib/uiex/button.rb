class Button < Window
  TEXT_ALIGN = { vertical_alignment_enum: 1, alignment_enum: 1 }.freeze

  include Hoverable

  def initialize(**args)
    super(args)

    @text_color = args[:text_color] || Color::BLACK
    @focus_color = args[:focus_color] || Color::WHITE
  end

  def handle_inputs
    super

    notify_observers(Event.new(:pressed, self)) if focussed? && accept?(relative_rect)
  end

  def to_primitives
    background_color = focussed? ? @focus_color : @color

    [
      relative_rect.solid!(**background_color.to_h),
      relative_center.label!(TEXT_ALIGN.merge(text: text, **@text_color.to_h))
    ]
  end
end

class DraggableButton < Button
  include Draggable
end

class GraphicalButton < Button
  attr_reader :frame_w
  attr_accessor :frame

  def initialize(**args)
    args[:background] = args[:path]
    args[:color] = args.fetch(:color, Color::TRANSPARENT)

    super(args)

    @frame = args.fetch(:frame, 1)
    @frame_w = args[:frame_w]
  end

  def path=(val)
    self.background = val
  end

  def path
    background
  end

  def to_primitives
    return unless visible?

    if frame_w && background
      [
        relative_rect.solid!(color.to_h),
        relative_rect.sprite!(path: background, source_x: frame_w * (frame - 1), source_w: frame_w)
      ] + @children.to_primitives
    else
      [
        relative_rect.solid!(color.to_h),
        relative_rect.sprite!(path: background)
      ] + @children.to_primitives
    end
  end
end

class Switch < Button
  def initialize(**args)
    super(args)

    @on = args.fetch(:on, true)
    @on_color = args.fetch(:on_color, Color::STEEL_BLUE)
    @text_color = args.fetch(:text_color, Color::DARK_GREY)
  end

  def set(on)
    @on = on
  end

  def on?
    @on
  end

  def to_primitives
    background_color = focussed? ? @focus_color : @color
    text_color = on? ? @on_color : @text_color

    [
      relative_rect.solid!(**background_color.to_h),
      relative_center.label!(TEXT_ALIGN.merge(text: text, **text_color.to_h))
    ]
  end
end

class GraphicalSwitch < Switch
  attr_reader :path

  def initialize(**args)
    super(args)

    @path = args[:path]
    @source_w = args.fetch(:source_w, w)
  end

  def to_primitives
    relative_rect.sprite!(path: path, source_x: on? ? 0 : @source_w, source_w: @source_w)
  end
end

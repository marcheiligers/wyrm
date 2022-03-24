class Image < Window
  def initialize(**args)
    args[:background] = args[:path]
    args[:color] = args.fetch(:color, Color::TRANSPARENT)

    super(args)
  end

  def path=(val)
    self.background = val
  end

  def path
    background
  end
end

class Sprite < Image
  attr_reader :frame_w
  attr_accessor :frame

  def initialize(**args)
    super(args)

    @frame = args.fetch(:frame, 1)
    @frame_w = args[:frame_w]
  end

  def to_primitives
    return unless visible?

    if frame_w && background
      [
        relative_rect.solid!(color.to_h),
        relative_rect.sprite!(path: background, source_x: frame_w * (frame - 1), source_w: frame_w)
      ] + @children.to_primitives
    else
      super
    end
  end
end

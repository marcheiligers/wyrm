class FocusRect < Window
  attr_reader :child

  def initialize(**args)
    @child = args[:child]

    args[:color] ||= Color::STEEL_BLUE
    args[:focussable] ||= false
    args[:visible] ||= !!@child

    super(args)
  end

  def focus(child)
    @child.blur if @child
    @child = child
    if @child
      show
      @child.focus
    else
      hide
    end
  end

  def blur
    @child.blur if @child
    @child = nil
  end

  def to_primitives
    return nil unless child

    rect = child.relative_rect

    [
      rect.merge(h: 2).solid!(color.to_h), # bottom
      rect.merge(y: rect.y + rect.h - 2, h: 2).solid!(color.to_h), # top
      rect.merge(w: 2).solid!(color.to_h), # left
      rect.merge(x: rect.x + rect.w - 2, w: 2).solid!(color.to_h) # right
    ]
  end
end

class GraphicalFocusRect < FocusRect
  attr_reader :path

  def initialize(**args)
    super(args)

    @path = args[:path]
  end

  def to_primitives
    return unless visible?

    relative_rect = child.relative_rect

    if w.to_i > 0
      relative_rect[:x] = child.x - (w - child.w) / 2
      relative_rect[:w] = w
    end

    if h.to_i > 0
      relative_rect[:y] = child.y - (h - child.h) / 2
      relative_rect[:h] = h
    end

    relative_rect.sprite!(path: path)
  end
end

module Draggable
  def initialize(**args)
    super(args)

    @dragging = false
  end

  def handle_inputs
    super

    if (result = $args.inputs.mouse.down) && result.inside_rect?(relative_rect)
      @dragging = true
      @drag_x = result.x - relative_x
      @drag_y = result.y - relative_y
      notify_observers(Event.new(:drag_start, self))
    end

    if dragging? && $args.inputs.mouse.up
      @dragging = false
      notify_observers(Event.new(:drag_end, self))
    end

    return unless dragging? && $args.inputs.mouse.moved

    @x += $args.inputs.mouse.x - relative_x - @drag_x
    @y += $args.inputs.mouse.y - relative_y - @drag_y
    limit_drag if dragging?
    notify_observers(Event.new(:drag_move, self))
  end

  def dragging?
    @dragging
  end

  def limit_drag
    # Override in a subclass to limit where the window can be dragged
  end
end

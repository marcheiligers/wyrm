module Hoverable
  def initialize(**args)
    super(args)

    @mouse_inside = false
  end

  def handle_inputs
    super

    if $args.inputs.mouse.inside_rect?(relative_rect)
      unless @mouse_inside
        notify_observers(Event.new(:mouse_enter, self))
        @mouse_inside = true
      end
    elsif @mouse_inside
      notify_observers(Event.new(:mouse_leave, self))
      @mouse_inside = false
    end
  end

  def hovered?
    @mouse_inside
  end
end

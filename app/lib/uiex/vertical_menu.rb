class VerticalMenu < Window
  attr_accessor :padding, :spacing
  attr_reader :focus_rect, :focus_rect_front, :default_height

  DEFAULT_HEIGHT = 40

  def initialize(**args)
    super(args)

    @padding = args.fetch(:padding, 0)
    @spacing = args.fetch(:spacing, 0)
    @focus_rect = args[:focus_rect]
    @focus_rect_front = args.fetch(:focus_rect_front, true)
    @default_height = args.fetch(:default_height, DEFAULT_HEIGHT)

    @debounce_input = DebounceInput.new(UP_DOWN_ARROW_KEYS) # TODO: UP_DOWN_ARROW_KEYS_AND_WS
  end

  # Statics cannot be selected or clicked. Think seperators or subtitles.
  def add_static(child)
    child.w = self.w - 2 * padding if child.w.to_i == 0
    child.h = DEFAULT_HEIGHT if child.h.to_i == 0
    child.x = (self.w - child.w) / 2 if child.x.to_i == 0
    child.y = calc_top - child.h if child.y.to_i == 0
    children.add(child)
  end

  def add_item(child)
    add_static(child)
    child.attach_observer(self)
  end

  def add_button(text)
    add_item(Button.new(text: text))
  end

  def add_separator
    add_static(HorizontalRule.new)
  end

  def observe(event)
    case event.name
    when :mouse_enter
      event.target.focus
      blur_children(event.target)
      focus_rect.focus(event.target) if focus_rect
    when :pressed
      puts "#{event.target} pressed"
    end
  end

  def handle_inputs
    return unless visible?

    super

    case @debounce_input.debounce
    when :up
      child = prev_focussable_child
      child.focus
      blur_children(child)
      focus_rect.focus(child) if focus_rect
    when :down
      child = next_focussable_child
      child.focus
      blur_children(child)
      focus_rect.focus(child) if focus_rect
    end
  end

  def to_primitives
    if focus_rect_front
      [super] + [focus_rect ? focus_rect.to_primitives : nil]
    else
      [focus_rect ? focus_rect.to_primitives : nil] + [super]
    end
  end

private
  def calc_top
    self.h - (children.inject(0) { |total, child| total + child.h } + spacing * children.length + padding)
  end

  def prev_focussable_child(cur_index = focussed_child_index)
    children[0..(cur_index ? cur_index - 1 : -1)].reverse.detect { |child| child.focussable? }
  end

  def next_focussable_child(cur_index = focussed_child_index)
    children[(cur_index ? cur_index + 1 : 0)..-1].detect { |child| child.focussable? } || next_focussable_child(nil)
  end
end

module InputEvents
  def input_accepted?(rect = nil)
    inputs = $args.inputs
    return true if inputs.controller_one.key_up.x || inputs.keyboard.key_up.enter || inputs.keyboard.key_up.space

    input_pressed?(rect)
  end

  def input_pressed?(rect = nil)
    if rect && (click = $args.inputs.mouse.click) # TODO: touch
      click.inside_rect?(relative_rect)
    end
  end
end

UP_DOWN_ARROW_KEYS = { up: :up, down: :down }
UP_DOWN_ARROW_KEYS_AND_WS = { up: :up, down: :down, w: :up, s: :down }

class DebounceInput
  def initialize(events, max_ticks = 20, accel = 0, min_ticks = 3)
    @events = events
    @max_ticks = max_ticks
    @accel = accel
    @min_ticks = min_ticks

    @event_ticks = 0
    @event_name = nil
    @current_debounce_ticks = @max_ticks
  end

  def debounce
    _input, event_name = @events.detect { |input, _name| $args.inputs.send(input) } # TODO: deal with keys
    if @event_name != event_name
      @event_ticks = 0
      @current_debounce_ticks = @max_ticks
      @event_name = event_name # returned
    elsif @event_name == event_name
      @event_ticks += 1
      if @event_ticks % @current_debounce_ticks == 0
        @current_debounce_ticks = [@current_debounce_ticks - @accel, @min_ticks].max
        @event_name # returned
      end
    end
  end
end


module InputManager
  DIRECTIONS = %i[up down left right].freeze
  WASD_DIRECTIONS = {
    up: :w,
    down: :s,
    left: :a,
    right: :d
  }.freeze
  NUMERIC_MAP = {
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    five: 5,
    six: 6,
    seven: 7,
    eight: 8,
    nine: 9,
    zero: 0,
  }.freeze

  def direction_down
    DIRECTIONS.detect { |sym| $args.keyboard.key_down.send(sym) } ||
      WASD_DIRECTIONS.detect { |_key, sym| $args.keyboard.key_down.send(sym) }&.first ||
      DIRECTIONS.detect { |sym| $args.controller_one.key_down.send(sym) }
  end

  def number_down
    NUMERIC_MAP.detect { |key, _num| $args.keyboard.key_down.send(key) }&.last
  end

  def accept?
    $args.keyboard.key_down.enter || $args.keyboard.key_down.space ||
      $args.controller_one.key_down.a || $args.controller_one.key_down.x ||
      $args.controller_one.key_down.select || $args.controller_one.key_down.start
  end

  def rect_clicked?(rect)
    (click = $args.inputs.mouse.click) && click.inside_rect?(relative_rect)
  end

  def reject?
    $args.keyboard.key_down.escape || $args.keyboard.key_down.delete ||
      $args.controller_one.key_down.y || $args.controller_one.key_down.b
  end

  def any_key_held?
    $args.keyboard.key_held.truthy_keys.length > 2 ||
      $args.controller_one.key_held.truthy_keys.length > 0
  end
end

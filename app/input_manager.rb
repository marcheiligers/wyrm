module InputManager
  DIRECTIONS = %i[up down left right].freeze
  WASD_DIRECTIONS = {
    up: :w,
    down: :s,
    left: :a,
    right: :d
  }.freeze

  def direction_down
    dir = DIRECTIONS.detect { |sym| $args.keyboard.key_down.send(sym) }
    dir ||= WASD_DIRECTIONS.detect { |_key, sym| $args.keyboard.key_down.send(sym) }&.first
    dir ||= DIRECTIONS.detect { |sym| $args.controller_one.key_down.send(sym) }
    dir
  end

  def accept?
    $args.keyboard.key_down.enter || $args.keyboard.key_down.space ||
      $args.controller_one.key_down.a || $args.controller_one.key_down.x ||
      $args.controller_one.key_down.select || $args.controller_one.key_down.start
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

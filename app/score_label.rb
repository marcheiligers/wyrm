class ScoreLabel
  include Numbers

  NO_FADE_DURATION = 30
  FADE_DURATION = 60
  TOTAL_DURATION = NO_FADE_DURATION + FADE_DURATION
  TOTAL_MOVE = GRID_SIZE * 2

  def initialize(x, y, points)
    @x = x - (points.to_s.length * GRID_SIZE).idiv(2)
    @y = y
    @points = points
    @move_animation_start = $args.tick_count
    @fade_animation_start = @move_animation_start + NO_FADE_DURATION
  end

  def finished?
    @move_animation_start + TOTAL_DURATION < $args.tick_count
  end

  def to_p
    return if finished?

    tick_count = $args.tick_count

    if tick_count < @fade_animation_start
      alpha_progress = 0
    else
      alpha_progress = $args.easing.ease(@fade_animation_start, tick_count, FADE_DURATION, :quad)
    end

    move_progress = $args.easing.ease(@move_animation_start, tick_count, TOTAL_DURATION, :quad)

    alpha = 255 * (1 - alpha_progress)
    dy = TOTAL_MOVE * move_progress

    draw_number(@x, @y + dy, @points, alpha)
  end
end

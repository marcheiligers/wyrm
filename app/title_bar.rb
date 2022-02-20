class TitleBar
  include Numbers

  BAR_Y = $args.grid.h - GRID_SIZE

  RECT = {
    x: 0,
    y: BAR_Y,
    w: $args.grid.w,
    h: GRID_SIZE,
    r: 0,
    g: 0,
    b: 0
  }.solid!

  TITLE = {
    x: GRID_SIZE,
    y: BAR_Y,
    w: GRID_SIZE * 4,
    h: GRID_SIZE,
    path: 'sprites/title-small.png'
  }.sprite!

  LEVEL = {
    x: GRID_SIZE * 7,
    y: BAR_Y,
    w: GRID_SIZE * 4,
    h: GRID_SIZE,
    path: 'sprites/level.png'
  }.sprite!

  LEVEL_X = 11 * GRID_SIZE
  SCORE_X = $args.grid.w - 6 * GRID_SIZE

  def initialize
    @gems = GEMS_PER_LEVEL.times.map { |i| Gem.new(14 + i, 17, true) }
  end

  def to_p
    @gems.each_with_index { |gem, i| $game.gems_left <= $game.gems_per_level - i - 1 ? gem.light! : gem.dark! }

    [RECT, TITLE, LEVEL, level, @gems.first($game.gems_per_level).map(&:to_p), score]
  end

  def level
    draw_number(LEVEL_X, BAR_Y, ($game.level + 1).to_s)
  end

  def score
    if $game.state == :new_game
      draw_number(SCORE_X, BAR_Y, $game.high_score.to_s.rjust(5, '0'))
    else
      draw_number(SCORE_X, BAR_Y, $game.score.to_s.rjust(5, '0'))
    end
  end
end

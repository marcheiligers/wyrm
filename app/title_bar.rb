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
    @coins = COINS_PER_LEVEL.times.map { |i| Coin.new(14 + i, 17, true) }
  end

  def to_p
    @coins.each_with_index { |coin, i| $game.coins_left <= $game.coins_per_level - i - 1 ? coin.light! : coin.dark! }

    [RECT, TITLE, LEVEL, level, @coins.first($game.coins_per_level).map(&:to_p), score]
  end

  def level
    if $game.state == :new_game
      draw_number(LEVEL_X, BAR_Y, ($game.high_level + 1).to_s)
    else
      draw_number(LEVEL_X, BAR_Y, ($game.level + 1).to_s)
    end
  end

  def score
    if $game.state == :new_game
      draw_number(SCORE_X, BAR_Y, $game.high_score.to_s.rjust(5, '0'))
    else
      draw_number(SCORE_X, BAR_Y, $game.score.to_s.rjust(5, '0'))
    end
  end
end

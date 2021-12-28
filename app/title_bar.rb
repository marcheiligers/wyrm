class TitleBar
	include Numbers

	# TODO: this really shouldn't be storing game state, just displaying it
	RECT = {
		x: 0,
		y: $gtk.args.grid.h - GRID_SIZE,
		w: $gtk.args.grid.w,
		h: GRID_SIZE,
		r: 0,
		g: 0,
		b: 0
	}.solid!

	SCORE_X = $gtk.args.grid.w - 6 * GRID_SIZE
	SCORE_Y = $gtk.args.grid.h - GRID_SIZE

	attr_reader :score, :gems_left

	def initialize
		reset
		@gems = 10.times.map { |i| Gem.new(10 + i, 17) }
	end

	def reset
		@score = 0
		@gems_left = 10
	end

	def new_level
		@gems_left = 10
	end

	def gem_eaten(points)
		@score += points
		@gems_left -= 1
	end

	def to_p
		[RECT, @gems.first(10 - @gems_left).map(&:to_p), score]
	end

  def score
    draw_number(SCORE_X, SCORE_Y, @score.to_s.rjust(5, '0'))
  end
end

class Sky
	RECT = {
		x: 0,
		y: 0,
		w: $gtk.args.grid.w,
		h: $gtk.args.grid.h
	}.solid!

	MORNING = { r: 238, g: 230, b: 148 }
	DAY = { r: 115, g: 194, b: 238 }
	AFTERNOON = { r: 90, g: 161, b: 213 }
	NIGHT = { r: 7, g: 11, b: 51 }

	COLORS = [
		MORNING,
		MORNING,
		DAY,
		DAY,
		DAY,
		AFTERNOON,
		AFTERNOON,
		NIGHT,
		NIGHT,
		NIGHT
	]

	def initialize
		@state = :clear
		@color = DAY
	end

	def night!
		@color = NIGHT
	end

	def to_p
		RECT.merge(COLORS[$game.level])
	end
end

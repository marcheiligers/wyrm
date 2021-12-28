class Sky
	RECT = {
		x: 0,
		y: 0,
		w: $gtk.args.grid.w,
		h: $gtk.args.grid.h
	}.solid!

	DAY = { r: 135, g: 206, b: 250 }
	NIGHT = { r: 7, g: 11, b: 51 }

	def initialize
		@state = :clear
		@color = DAY
	end

	def night!
		@color = NIGHT
	end

	def to_p
		RECT.merge(@color)
	end
end
